#ifndef OSCARET_CAPTURE_H
#define OSCARET_CAPTURE_H

static_assert(F_CPU == 16000000UL, "OSCARET requiere un reloj de CPU de 16 MHz");

// ATmega328P a 16 MHz. Retardos constantes, sin depender del optimizador.
// LDI + DEC/BRNE consumen exactamente 3*N ciclos.
#define OSCARET_DELAY(cycles) \
  ".if (" cycles ") / 3\n\t" \
  "ldi r19, (" cycles ") / 3\n\t" \
  "8: dec r19\n\t" \
  "brne 8b\n\t" \
  ".endif\n\t" \
  ".rept (" cycles ") %% 3\n\t" \
  "nop\n\t" \
  ".endr\n\t"

// Comparaciones sin signo. En bajada se invierten los operandos:
// anterior > nivel && actual <= nivel. En subida: anterior < nivel && actual >= nivel.
// Los dos caminos sin cruce llegan a 3 en el ciclo 8; el cruce llega a 4
// tambien en el ciclo 8. No hay hueco entre predisparo, cruce y captura.
// RXC0 aborta sin leer UDR0: la ISR de Arduino recibe el byte al restaurar SREG.
#define OSCARET_TRIGGER_BODY(previous, current) \
  "in r20, %[pinc]\n\t" \
  "andi r20, 0x3f\n\t" \
  OSCARET_DELAY("%[period] - 2") \
  "1: in r18, %[pinc]\n\t" \
  "andi r18, 0x3f\n\t" \
  previous \
  "brlo 2f\n\t" \
  "nop\n\t" \
  "nop\n\t" \
  "rjmp 3f\n\t" \
  "2:\n\t" \
  current \
  "brsh 4f\n\t" \
  "nop\n\t" \
  "3: mov r20, r18\n\t" \
  "lds r18, %[uart]\n\t" \
  "sbrc r18, %[rxc]\n\t" \
  "rjmp 9f\n\t" \
  OSCARET_DELAY("%[period] - 15") \
  "rjmp 1b\n\t" \
  "4: st Z+, r20\n\t" \
  "st Z+, r18\n\t" \
  OSCARET_DELAY("%[period] - 12") \
  "5: in r18, %[pinc]\n\t" \
  "andi r18, 0x3f\n\t" \
  "st Z+, r18\n\t" \
  "lds r18, %[uart]\n\t" \
  "sbrc r18, %[rxc]\n\t" \
  "rjmp 9f\n\t" \
  OSCARET_DELAY("%[period] - 12") \
  "sbiw %[count], 1\n\t" \
  "brne 5b\n\t" \
  "9:\n\t"

// ---------------------------------------------
template <unsigned period>
static void capture_free(volatile byte *buffer, uint16_t size)
{
  byte *ptr = (byte *)buffer;
  uint16_t count = size;
  asm volatile(
    "1: in r18, %[pinc]\n\t"
    "andi r18, 0x3f\n\t"
    "st Z+, r18\n\t"
    OSCARET_DELAY("%[period] - 8")
    "sbiw %[count], 1\n\t"
    "brne 1b\n\t"
    : "+&z" (ptr), [count] "+&w" (count)
    : [pinc] "I" (_SFR_IO_ADDR(PINC)), [period] "n" (period)
    : "r18", "r19", "cc", "memory"
  );
  return;
}

// ---------------------------------------------
template <unsigned period>
static bool capture_trigger(volatile byte *buffer, uint16_t size, byte level, bool rising)
{
  static_assert(period >= 16, "El trigger necesita al menos 16 ciclos por muestra");
  byte *ptr = (byte *)buffer;
  uint16_t count = size - 2;
  if (rising)
  {
    asm volatile(
      OSCARET_TRIGGER_BODY("cp r20, %[level]\n\t", "cp r18, %[level]\n\t")
      : "+&z" (ptr), [count] "+&w" (count)
      : [pinc] "I" (_SFR_IO_ADDR(PINC)), [level] "r" (level),
        [uart] "n" (_SFR_MEM_ADDR(UCSR0A)), [rxc] "I" (RXC0), [period] "n" (period)
      : "r18", "r19", "r20", "cc", "memory"
    );
  }
  else
  {
    asm volatile(
      OSCARET_TRIGGER_BODY("cp %[level], r20\n\t", "cp %[level], r18\n\t")
      : "+&z" (ptr), [count] "+&w" (count)
      : [pinc] "I" (_SFR_IO_ADDR(PINC)), [level] "r" (level),
        [uart] "n" (_SFR_MEM_ADDR(UCSR0A)), [rxc] "I" (RXC0), [period] "n" (period)
      : "r18", "r19", "r20", "cc", "memory"
    );
  }
  return count == 0;
}

#endif
