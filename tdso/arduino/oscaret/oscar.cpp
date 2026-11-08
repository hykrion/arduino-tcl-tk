#include "oscar.h"
#include "capture.h"

#include <util/atomic.h>

// Cabecera frames
static const byte FRAME_HEADER[] = { 0xA5, 0x5A, 0xC3, 0x3C };

// OC1B = PB2 = Arduino D10
static const byte CA3306_CLK_PIN = 10;
static const byte CA3306_CLK_BIT = PB2;

static const int BUFFER_SIZE = 1024;
static volatile byte m_buffer[BUFFER_SIZE];

// Public
// ----------------------------------------------

// ----------------------------------------------
void Oscar::add_char_command(char c)
{
  if (c != '\r' && c != '\n')
  {
    if (m_commandCount < MAX_COMMAND - 1)
      m_command[m_commandCount++] = c;
    else
      m_commandCount = MAX_COMMAND; // No envolver ni interpretar un sufijo como comando.
  }
  return;
}

// ---------------------------------------------
void Oscar::aquire_and_send()
{
  byte savedSREG = SREG;
  noInterrupts();
  bool ready = false;
  // No entrar en espera mientras Arduino tiene bytes o un comando incompleto.
  // Comprobar la cola con interrupciones deshabilitadas evita una carrera con RX.
  if (m_commandCount == 0 && Serial.available() == 0)
  {
    ready = true;
    if (m_triggerLevel != 0)
    {
      switch (m_mode)
      {
        case FS5MSPS:
        case FS2MSPS:
        case FS1MSPS: ready = capture_trigger<16>(m_buffer, BUFFER_SIZE, m_triggerLevel, m_triggerRising); break;
        case FS500KSPS: ready = capture_trigger<32>(m_buffer, BUFFER_SIZE, m_triggerLevel, m_triggerRising); break;
        case FS250KSPS: ready = capture_trigger<64>(m_buffer, BUFFER_SIZE, m_triggerLevel, m_triggerRising); break;
        case FS125KSPS: ready = capture_trigger<128>(m_buffer, BUFFER_SIZE, m_triggerLevel, m_triggerRising); break;
        case FS50KSPS: ready = capture_trigger<320>(m_buffer, BUFFER_SIZE, m_triggerLevel, m_triggerRising); break;
        case FS25KSPS: ready = capture_trigger<640>(m_buffer, BUFFER_SIZE, m_triggerLevel, m_triggerRising); break;
      }
    }
    else
    {
      switch (m_mode)
      {
        case FS5MSPS: aquire_and_send_5Msps(); break;
        case FS2MSPS: aquire_and_send_2Msps(); break;
        case FS1MSPS: aquire_and_send_1Msps(); break;
        case FS500KSPS: aquire_and_send_500ksps(); break;
        case FS250KSPS: aquire_and_send_250ksps(); break;
        case FS125KSPS: aquire_and_send_125ksps(); break;
        case FS50KSPS: aquire_and_send_50ksps(); break;
        case FS25KSPS: aquire_and_send_25ksps(); break;
      }
    }
  }
  SREG = savedSREG;
  if (ready)
    send_buffer();
  return;
}

// ---------------------------------------------
void Oscar::aquire_and_send_125ksps()
{
  capture_free<128>(m_buffer, BUFFER_SIZE);
  return;
}

// ---------------------------------------------
void Oscar::aquire_and_send_1Msps()
{
  capture_free<16>(m_buffer, BUFFER_SIZE);
  return;
}

// ---------------------------------------------
void Oscar::aquire_and_send_250ksps()
{
  capture_free<64>(m_buffer, BUFFER_SIZE);
  return;
}

// ---------------------------------------------
void Oscar::aquire_and_send_25ksps()
{
  capture_free<640>(m_buffer, BUFFER_SIZE);
  return;
}

// ---------------------------------------------
void Oscar::aquire_and_send_2Msps()
{
  capture_free<8>(m_buffer, BUFFER_SIZE);
  return;
}

// ---------------------------------------------
void Oscar::aquire_and_send_500ksps()
{
  capture_free<32>(m_buffer, BUFFER_SIZE);
  return;
}

// ---------------------------------------------
void Oscar::aquire_and_send_50ksps()
{
  capture_free<320>(m_buffer, BUFFER_SIZE);
  return;
}

// ---------------------------------------------
// GCC no cuenta la expansion de .rept al calcular el alcance de los saltos.
// Mantener este bloque de 4096 bytes fuera del llamador, tambien con LTO.
__attribute__((noinline)) void Oscar::aquire_and_send_5Msps()
{
  byte *ptr = (byte *)m_buffer;
  // 1024 muestras reales, 3 ciclos por muestra (5.333 Msps a 16 MHz).
  asm volatile(
    ".rept 1024\n\t"
    "in r18, %[pinc]\n\t"
    "st Z+, r18\n\t"
    ".endr\n\t"
    : "+z" (ptr)
    : [pinc] "I" (_SFR_IO_ADDR(PINC))
    : "r18", "memory"
  );
  for (int i = 0; i < BUFFER_SIZE; ++i)
    m_buffer[i] &= 0x3f;
  return;
}

// ---------------------------------------------
char Oscar::get_command()
{
  return m_command[0];
}

// ---------------------------------------------
double Oscar::get_float_from_command()
{
  char cmd[MAX_COMMAND] = {'\0'};
  
  for(int i = 0; i < MAX_COMMAND - 1; i++)
    cmd[i] = m_command[i + 1];
  
  return atof(cmd);
}

// ---------------------------------------------
int Oscar::get_int_from_command()
{
  char cmd[MAX_COMMAND] = {'\0'};
  
  for(int i = 0; i < MAX_COMMAND - 1; i++)
    cmd[i] = m_command[i + 1];
  
  return atoi(cmd);
}

// ---------------------------------------------
Oscar::Oscar()
{
  reset_command();
  m_mode = FS5MSPS;
  m_triggerLevel = 0;
  m_triggerRising = true;
}

// ---------------------------------------------
void Oscar::pinc_setup()
{
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  pinMode(A5, INPUT);
}

// ---------------------------------------------
void Oscar::rele_setup()
{
  pinMode(ACDC, OUTPUT);
  pinMode(SEN1, OUTPUT);
  pinMode(SEN2, OUTPUT);
}

// ---------------------------------------------
void Oscar::reset_command()
{
  memset(m_command, '\0', MAX_COMMAND);
  m_commandCount = 0;
}

// ---------------------------------------------
void Oscar::send_buffer()
{
  // Cabecera de la trama
  Serial.write(FRAME_HEADER, sizeof(FRAME_HEADER));

  Serial.write((byte*)m_buffer, BUFFER_SIZE);
  //Serial.println(int(m_buffer[128]));
  Serial.flush();
}

// ---------------------------------------------
void Oscar::set_acdc()
{
  int mode = get_int_from_command();
  
  switch(mode)
  {
    case DC:
      digitalWrite(ACDC, LOW);
      break;
    case AC:
      digitalWrite(ACDC, HIGH);
      break;
  }
}

// ---------------------------------------------
void Oscar::set_ca3306_clock(uint32_t fs)
{
  fs *= 1000;
  // Número de ciclos de CPU por periodo de muestreo.
  // Redondeamos al entero más cercano.
  uint32_t ticks = (F_CPU + fs / 2) / fs;
  
  // No interesa superar 5.33 Msps porque Arduino
  // no va a poder leer más rápido:
  // 16 MHz / 3 ciclos/instrucción = 5.333 Msps
  if (ticks < 3) {
    ticks = 3;
  }
  
  if (ticks > 65536UL) {
    ticks = 65536UL;
  }
  
  uint16_t top = ticks - 1;
  
  // Duty aproximado del 50%.
  // Con pocos ticks, por ejemplo ticks = 3, no se puede obtener
  // exactamente 50%, pero sí un reloj usable.
  uint16_t ocr = (ticks / 2) - 1;
  
  if (ocr >= top) {
    ocr = top - 1;
  }
  
  // Para fs = 5.333 MHz: TOP = 2, OCR1B = 1
  // Duty = 67/33%
  if (top <= 2) {
    ocr = 1;
  }
  
  uint32_t fs_real = F_CPU / ticks;
  
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    // Parar Timer1 mientras se reconfigura
    TCCR1A = 0;
    TCCR1B = 0;
    TCNT1  = 0;
    
    // Pin OC1B como salida: Arduino D10
    DDRB |= _BV(CA3306_CLK_BIT);
    
    // TOP del PWM
    ICR1 = top;
    
    // Duty aproximado 50%
    OCR1B = ocr;
    
    // Fast PWM modo 14:
    // WGM13:0 = 1110 -> TOP = ICR1
    // COM1B1 = 1 -> salida PWM no inversora por OC1B
    // CS10 = 1 -> sin prescaler
    TCCR1A = _BV(COM1B1) | _BV(WGM11);
    TCCR1B = _BV(WGM13) | _BV(WGM12) | _BV(CS10);
  }
}

// ---------------------------------------------
void Oscar::set_fs()
{
  if (m_commandCount == 2 && m_command[1] >= '0' && m_command[1] <= '7')
  {
    m_mode = m_command[1] - '0';
    update_clock();
  }
  return;
}

// ---------------------------------------------
void Oscar::set_sen1()
{
  int mode = get_int_from_command();
  
  switch(mode)
  {
    case S_10MV:
      digitalWrite(SEN1, LOW);
      break;
    case S_1V:
      digitalWrite(SEN1, HIGH);
      break;
  }
}

// ---------------------------------------------
void Oscar::set_sen2()
{
  int mode = get_int_from_command();
  
  switch(mode)
  {
    case X1 :
      digitalWrite(SEN2, LOW);
      break;
    case X5:
      digitalWrite(SEN2, HIGH);
      break;
  }
}

// ---------------------------------------------
void Oscar::set_trigger()
{
  int level = 0;
  bool valid = (m_commandCount >= 2 && m_commandCount <= 3);
  for (byte i = 1; i < m_commandCount && valid; ++i)
  {
    char c = m_command[i];
    if (c < '0' || c > '9')
      valid = false;
    else
      level = level * 10 + c - '0';
  }
  if (valid && level <= 63)
  {
    m_triggerLevel = (byte)level;
    update_clock();
  }
  return;
}

// ---------------------------------------------
void Oscar::set_trigger_slope()
{
  if (m_commandCount == 2 && (m_command[1] == '0' || m_command[1] == '1'))
    m_triggerRising = (m_command[1] == '1');
  return;
}

// ---------------------------------------------
void Oscar::setup()
{
  pinc_setup();
  rele_setup();
  delay(1500);
  // TODO Ver a que velocidad lo queremos inicialmente
  update_clock();
}

// ---------------------------------------------
void Oscar::update_clock()
{
  static const uint16_t rates[] = {5000, 2000, 1000, 500, 250, 125, 50, 25};
  byte mode = m_mode;
  if (m_triggerLevel != 0 && mode < FS1MSPS)
    mode = FS1MSPS;
  set_ca3306_clock(rates[mode]);
  return;
}
