#include "OSCAR.h"

#include <util/atomic.h>

// Cabecera frames
static const byte FRAME_HEADER[] = { 0xA5, 0x5A, 0xC3, 0x3C };

// OC1B = PB2 = Arduino D10
static const byte CA3306_CLK_PIN = 10;
static const byte CA3306_CLK_BIT = PB2;

static const int BUFFER_SIZE = 1024;
static volatile byte m_buffer[BUFFER_SIZE];

// NOTE 3x = delay.
//  eje: 32ciclos = 24 + 8(fijos del bucle)
//  3x = 24; x = 8 --> delay = 8
#define OSCAR_CAPTURE_LOOP()                                  \
  asm volatile(                                               \
    "1:\n\t"                                                  \
    "in r18, %[pinc]\n\t"        /* 1 ciclo */                \
    "andi r18, 0x3F\n\t"         /* 1 ciclo */                \
    "st Z+, r18\n\t"             /* 2 ciclos */               \
                                                              \
    "mov r19, %[delay]\n\t"      /* 1 ciclo */                \
    "2:\n\t"                                                  \
    "dec r19\n\t"                /* delay * 1 ciclo */        \
    "brne 2b\n\t"                /* 2 ciclos si salta, 1 no */\
                                                              \
    "sbiw %[count], 1\n\t"       /* 2 ciclos */               \
    "brne 1b\n\t"                /* 2 ciclos salvo última */  \
    : "+z" (ptr), [count] "+w" (count)                        \
    : [pinc] "I" (_SFR_IO_ADDR(PINC)),                        \
      [delay] "r" (delay)                                     \
    : "r18", "r19", "memory"                                  \
  )
  
// ----------------------------------------------
// Public
// ----------------------------------------------

// ----------------------------------------------
Oscar::Oscar()
{
  reset_command();
  m_mode = FS5MSPS;
}

// ----------------------------------------------
void Oscar::add_char_command(char c)
{
  if (c != '\r' && c != '\n')
  {
    m_command[m_commandCount] = c;
    m_commandCount = (m_commandCount + 1) % MAX_COMMAND;
  }
}

// ----------------------------------------------
void Oscar::aquire_and_send()
{
  noInterrupts();
  
  switch(m_mode) {
    case FS5MSPS:
      aquire_and_send_5Msps();
      break;
    case FS2MSPS:
      aquire_and_send_2Msps();
      break;
    case FS1MSPS:
      aquire_and_send_1Msps();
      break;
    case FS500KSPS:
      aquire_and_send_500ksps();
      break;
    case FS250KSPS:
      aquire_and_send_250ksps();
      break;
    case FS125KSPS:
      aquire_and_send_125ksps();
      break;
    case FS50KSPS:
      aquire_and_send_50ksps();
      break;
    case FS25KSPS:
      aquire_and_send_25ksps();
      break;
  }
  
  interrupts();
  
  send_buffer();
}

// ----------------------------------------------
// NOTE 8 ciclos / muestra
void Oscar::aquire_and_send_2Msps()
{
  /*
  for(int i = 0; i < 512; i++)
  {
    m_buffer[i] = PINC;
  }
  */
  
  uint8_t *ptr = (uint8_t *)m_buffer;
  uint16_t count = BUFFER_SIZE;
  
  asm volatile(
    "1:\n\t"
    "in r18, %[pinc]\n\t"   // 1 ciclo
    "andi r18, 0x3F\n\t"    // 1 ciclo
    "st Z+, r18\n\t"        // 2 ciclos
    "sbiw %[count], 1\n\t"  // 2 ciclos
    "brne 1b\n\t"           // 2 ciclos
    : "+z" (ptr), [count] "+w" (count)
    : [pinc] "I" (_SFR_IO_ADDR(PINC))
    : "r18", "memory"
  );
}

// ----------------------------------------------
// NOTE 16 ciclos / muestra
void Oscar::aquire_and_send_1Msps()
{
  uint8_t *ptr = (uint8_t *)m_buffer;
  uint16_t count = BUFFER_SIZE;
  
  // NOTE 16 (8+8) ciclos de reloj
  asm volatile(
    "1:\n\t"
    "in r18, %[pinc]\n\t" // 1 ciclo
    "andi r18, 0x3F\n\t"  // 1 ciclo
    "st Z+, r18\n\t"      // 2 ciclos
    
    "nop\n\t" // 1 ciclo...
    "nop\n\t"
    "nop\n\t"
    "nop\n\t"
    "nop\n\t"
    "nop\n\t"
    "nop\n\t"
    "nop\n\t"

    "sbiw %[count], 1\n\t"  // 2 ciclos
    "brne 1b\n\t"           // 2 ciclos
    : "+z" (ptr), [count] "+w" (count)
    : [pinc] "I" (_SFR_IO_ADDR(PINC))
    : "r18", "memory"
  );
}

// ----------------------------------------------
// NOTE 32 ciclos / muestra
void Oscar::aquire_and_send_500ksps()
{
  uint8_t *ptr = (uint8_t *)m_buffer;
  uint16_t count = BUFFER_SIZE;
  uint8_t delay = 8;
  
  OSCAR_CAPTURE_LOOP();
}

// ----------------------------------------------
// NOTE 64 ciclos / muestra
void Oscar::aquire_and_send_250ksps()
{
  uint8_t *ptr = (uint8_t *)m_buffer;
  uint16_t count = BUFFER_SIZE;
  
  uint8_t delay = 18;
  
  OSCAR_CAPTURE_LOOP();
}

// ----------------------------------------------
// NOTE 128 ciclos / muestra
void Oscar::aquire_and_send_125ksps()
{
  uint8_t *ptr = (uint8_t *)m_buffer;
  uint16_t count = BUFFER_SIZE;
  uint8_t delay = 40;
  
  OSCAR_CAPTURE_LOOP();
}

// ----------------------------------------------
// NOTE 320 ciclos / muestra
void Oscar::aquire_and_send_50ksps()
{
  uint8_t *ptr = (uint8_t *)m_buffer;
  uint16_t count = BUFFER_SIZE;
  uint8_t delay = 104;
  
  OSCAR_CAPTURE_LOOP();
}

// ----------------------------------------------
// NOTE 640 ciclos / muestra
void Oscar::aquire_and_send_25ksps()
{
  uint8_t *ptr = (uint8_t *)m_buffer;
  uint16_t count = BUFFER_SIZE;
  
  asm volatile(
    "1:\n\t"
    "in r18, %[pinc]\n\t" // 1 ciclo
    "andi r18, 0x3F\n\t"  // 1 ciclo
    "st Z+, r18\n\t"      // 2 ciclos
    
    // Retardo adicional: 632 ciclos
    "ldi r19, 210\n\t" // 1 ciclo
    "2:\n\t"
    "dec r19\n\t"     // 210 * 1 ciclo
    "brne 2b\n\t"     // 209 * 2 + 1 * 1 ciclos
    
    "nop\n\t" // 1 ciclo
    "nop\n\t"
    
    "sbiw %A[count], 1\n\t" // 2 ciclos
    "brne 1b\n\t"           // 2 ciclos normalmente
    : "+z" (ptr), [count] "+w" (count)
    : [pinc] "I" (_SFR_IO_ADDR(PINC))
    : "r18", "r19", "memory"
  );
}

// ----------------------------------------------
char Oscar::get_command()
{
  return m_command[0];
}

// ----------------------------------------------
void Oscar::reset_command()
{
  memset(m_command, '\0', MAX_COMMAND);
  m_commandCount = 0;
}

// ----------------------------------------------
void Oscar::send_buffer()
{
  // Cabecera de la trama
  Serial.write(FRAME_HEADER, sizeof(FRAME_HEADER));

  Serial.write((byte*)m_buffer, BUFFER_SIZE);
  //Serial.println(int(m_buffer[128]));
  Serial.flush();
}

// ----------------------------------------------
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

// ----------------------------------------------
// @param fs  in (ksps)
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

// ----------------------------------------------
void Oscar::set_fs()
{
  int mode = get_int_from_command();
  
  switch(mode)
  {
    case 0:
      set_ca3306_clock(5000);
      m_mode = FS5MSPS;
      break;
    case 1:
      set_ca3306_clock(2000);
      m_mode = FS2MSPS;
      break;
    case 2:
      set_ca3306_clock(1000);
      m_mode = FS1MSPS;
      break;
    case 3:
      set_ca3306_clock(500);
      m_mode = FS500KSPS;
      break;
    case 4:
      set_ca3306_clock(250);
      m_mode = FS250KSPS;
      break;
    case 5:
      set_ca3306_clock(125);
      m_mode = FS125KSPS;
      break;
    case 6:
      set_ca3306_clock(50);
      m_mode = FS50KSPS;
      break;
    case 7:
      set_ca3306_clock(25);
      m_mode = FS25KSPS;
      break;
  }
}

// ----------------------------------------------
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

// ----------------------------------------------
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

// ----------------------------------------------
void Oscar::setup()
{
  pinc_setup();
  rele_setup();
  delay(1500);
  // TODO Ver a que velocidad lo queremos inicialmente
  set_ca3306_clock(5000);
}

// ----------------------------------------------
// Private
// ----------------------------------------------

// ----------------------------------------------
double Oscar::get_float_from_command()
{
  char cmd[MAX_COMMAND] = {'\0'};
  
  for(int i = 0; i < MAX_COMMAND - 1; i++)
    cmd[i] = m_command[i + 1];
  
  return atof(cmd);
}

// ----------------------------------------------
int Oscar::get_int_from_command()
{
  char cmd[MAX_COMMAND] = {'\0'};
  
  for(int i = 0; i < MAX_COMMAND - 1; i++)
    cmd[i] = m_command[i + 1];
  
  return atoi(cmd);
}

// ----------------------------------------------
void Oscar::pinc_setup()
{
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  pinMode(A5, INPUT);
}

// ----------------------------------------------
void Oscar::rele_setup()
{
  pinMode(ACDC, OUTPUT);
  pinMode(SEN1, OUTPUT);
  pinMode(SEN2, OUTPUT);
}

// ----------------------------------------------
void Oscar::aquire_and_send_5Msps()
{
  m_buffer[0] = PINC;
  m_buffer[1] = PINC;
  m_buffer[2] = PINC;
  m_buffer[3] = PINC;
  m_buffer[4] = PINC;
  m_buffer[5] = PINC;
  m_buffer[6] = PINC;
  m_buffer[7] = PINC;
  m_buffer[8] = PINC;
  m_buffer[9] = PINC;
  m_buffer[10] = PINC;
  m_buffer[11] = PINC;
  m_buffer[12] = PINC;
  m_buffer[13] = PINC;
  m_buffer[14] = PINC;
  m_buffer[15] = PINC;
  m_buffer[16] = PINC;
  m_buffer[17] = PINC;
  m_buffer[18] = PINC;
  m_buffer[19] = PINC;
  m_buffer[20] = PINC;
  m_buffer[21] = PINC;
  m_buffer[22] = PINC;
  m_buffer[23] = PINC;
  m_buffer[24] = PINC;
  m_buffer[25] = PINC;
  m_buffer[26] = PINC;
  m_buffer[27] = PINC;
  m_buffer[28] = PINC;
  m_buffer[29] = PINC;
  m_buffer[30] = PINC;
  m_buffer[31] = PINC;
  m_buffer[32] = PINC;
  m_buffer[33] = PINC;
  m_buffer[34] = PINC;
  m_buffer[35] = PINC;
  m_buffer[36] = PINC;
  m_buffer[37] = PINC;
  m_buffer[38] = PINC;
  m_buffer[39] = PINC;
  m_buffer[40] = PINC;
  m_buffer[41] = PINC;
  m_buffer[42] = PINC;
  m_buffer[43] = PINC;
  m_buffer[44] = PINC;
  m_buffer[45] = PINC;
  m_buffer[46] = PINC;
  m_buffer[47] = PINC;
  m_buffer[48] = PINC;
  m_buffer[49] = PINC;
  m_buffer[50] = PINC;
  m_buffer[51] = PINC;
  m_buffer[52] = PINC;
  m_buffer[53] = PINC;
  m_buffer[54] = PINC;
  m_buffer[55] = PINC;
  m_buffer[56] = PINC;
  m_buffer[57] = PINC;
  m_buffer[58] = PINC;
  m_buffer[59] = PINC;
  m_buffer[60] = PINC;
  m_buffer[61] = PINC;
  m_buffer[62] = PINC;
  m_buffer[63] = PINC;
  m_buffer[64] = PINC;
  m_buffer[65] = PINC;
  m_buffer[66] = PINC;
  m_buffer[67] = PINC;
  m_buffer[68] = PINC;
  m_buffer[69] = PINC;
  m_buffer[70] = PINC;
  m_buffer[71] = PINC;
  m_buffer[72] = PINC;
  m_buffer[73] = PINC;
  m_buffer[74] = PINC;
  m_buffer[75] = PINC;
  m_buffer[76] = PINC;
  m_buffer[77] = PINC;
  m_buffer[78] = PINC;
  m_buffer[79] = PINC;
  m_buffer[80] = PINC;
  m_buffer[81] = PINC;
  m_buffer[82] = PINC;
  m_buffer[83] = PINC;
  m_buffer[84] = PINC;
  m_buffer[85] = PINC;
  m_buffer[86] = PINC;
  m_buffer[87] = PINC;
  m_buffer[88] = PINC;
  m_buffer[89] = PINC;
  m_buffer[90] = PINC;
  m_buffer[91] = PINC;
  m_buffer[92] = PINC;
  m_buffer[93] = PINC;
  m_buffer[94] = PINC;
  m_buffer[95] = PINC;
  m_buffer[96] = PINC;
  m_buffer[97] = PINC;
  m_buffer[98] = PINC;
  m_buffer[99] = PINC;
  m_buffer[100] = PINC;
  m_buffer[101] = PINC;
  m_buffer[102] = PINC;
  m_buffer[103] = PINC;
  m_buffer[104] = PINC;
  m_buffer[105] = PINC;
  m_buffer[106] = PINC;
  m_buffer[107] = PINC;
  m_buffer[108] = PINC;
  m_buffer[109] = PINC;
  m_buffer[110] = PINC;
  m_buffer[111] = PINC;
  m_buffer[112] = PINC;
  m_buffer[113] = PINC;
  m_buffer[114] = PINC;
  m_buffer[115] = PINC;
  m_buffer[116] = PINC;
  m_buffer[117] = PINC;
  m_buffer[118] = PINC;
  m_buffer[119] = PINC;
  m_buffer[120] = PINC;
  m_buffer[121] = PINC;
  m_buffer[122] = PINC;
  m_buffer[123] = PINC;
  m_buffer[124] = PINC;
  m_buffer[125] = PINC;
  m_buffer[126] = PINC;
  m_buffer[127] = PINC;
  m_buffer[128] = PINC;
  m_buffer[129] = PINC;
  m_buffer[130] = PINC;
  m_buffer[131] = PINC;
  m_buffer[132] = PINC;
  m_buffer[133] = PINC;
  m_buffer[134] = PINC;
  m_buffer[135] = PINC;
  m_buffer[136] = PINC;
  m_buffer[137] = PINC;
  m_buffer[138] = PINC;
  m_buffer[139] = PINC;
  m_buffer[140] = PINC;
  m_buffer[141] = PINC;
  m_buffer[142] = PINC;
  m_buffer[143] = PINC;
  m_buffer[144] = PINC;
  m_buffer[145] = PINC;
  m_buffer[146] = PINC;
  m_buffer[147] = PINC;
  m_buffer[148] = PINC;
  m_buffer[149] = PINC;
  m_buffer[150] = PINC;
  m_buffer[151] = PINC;
  m_buffer[152] = PINC;
  m_buffer[153] = PINC;
  m_buffer[154] = PINC;
  m_buffer[155] = PINC;
  m_buffer[156] = PINC;
  m_buffer[157] = PINC;
  m_buffer[158] = PINC;
  m_buffer[159] = PINC;
  m_buffer[160] = PINC;
  m_buffer[161] = PINC;
  m_buffer[162] = PINC;
  m_buffer[163] = PINC;
  m_buffer[164] = PINC;
  m_buffer[165] = PINC;
  m_buffer[166] = PINC;
  m_buffer[167] = PINC;
  m_buffer[168] = PINC;
  m_buffer[169] = PINC;
  m_buffer[170] = PINC;
  m_buffer[171] = PINC;
  m_buffer[172] = PINC;
  m_buffer[173] = PINC;
  m_buffer[174] = PINC;
  m_buffer[175] = PINC;
  m_buffer[176] = PINC;
  m_buffer[177] = PINC;
  m_buffer[178] = PINC;
  m_buffer[179] = PINC;
  m_buffer[180] = PINC;
  m_buffer[181] = PINC;
  m_buffer[182] = PINC;
  m_buffer[183] = PINC;
  m_buffer[184] = PINC;
  m_buffer[185] = PINC;
  m_buffer[186] = PINC;
  m_buffer[187] = PINC;
  m_buffer[188] = PINC;
  m_buffer[189] = PINC;
  m_buffer[190] = PINC;
  m_buffer[191] = PINC;
  m_buffer[192] = PINC;
  m_buffer[193] = PINC;
  m_buffer[194] = PINC;
  m_buffer[195] = PINC;
  m_buffer[196] = PINC;
  m_buffer[197] = PINC;
  m_buffer[198] = PINC;
  m_buffer[199] = PINC;
  m_buffer[200] = PINC;
  m_buffer[201] = PINC;
  m_buffer[202] = PINC;
  m_buffer[203] = PINC;
  m_buffer[204] = PINC;
  m_buffer[205] = PINC;
  m_buffer[206] = PINC;
  m_buffer[207] = PINC;
  m_buffer[208] = PINC;
  m_buffer[209] = PINC;
  m_buffer[210] = PINC;
  m_buffer[211] = PINC;
  m_buffer[212] = PINC;
  m_buffer[213] = PINC;
  m_buffer[214] = PINC;
  m_buffer[215] = PINC;
  m_buffer[216] = PINC;
  m_buffer[217] = PINC;
  m_buffer[218] = PINC;
  m_buffer[219] = PINC;
  m_buffer[220] = PINC;
  m_buffer[221] = PINC;
  m_buffer[222] = PINC;
  m_buffer[223] = PINC;
  m_buffer[224] = PINC;
  m_buffer[225] = PINC;
  m_buffer[226] = PINC;
  m_buffer[227] = PINC;
  m_buffer[228] = PINC;
  m_buffer[229] = PINC;
  m_buffer[230] = PINC;
  m_buffer[231] = PINC;
  m_buffer[232] = PINC;
  m_buffer[233] = PINC;
  m_buffer[234] = PINC;
  m_buffer[235] = PINC;
  m_buffer[236] = PINC;
  m_buffer[237] = PINC;
  m_buffer[238] = PINC;
  m_buffer[239] = PINC;
  m_buffer[240] = PINC;
  m_buffer[241] = PINC;
  m_buffer[242] = PINC;
  m_buffer[243] = PINC;
  m_buffer[244] = PINC;
  m_buffer[245] = PINC;
  m_buffer[246] = PINC;
  m_buffer[247] = PINC;
  m_buffer[248] = PINC;
  m_buffer[249] = PINC;
  m_buffer[250] = PINC;
  m_buffer[251] = PINC;
  m_buffer[252] = PINC;
  m_buffer[253] = PINC;
  m_buffer[254] = PINC;
  m_buffer[255] = PINC;
  m_buffer[256] = PINC;
  m_buffer[257] = PINC;
  m_buffer[258] = PINC;
  m_buffer[259] = PINC;
  m_buffer[260] = PINC;
  m_buffer[261] = PINC;
  m_buffer[262] = PINC;
  m_buffer[263] = PINC;
  m_buffer[264] = PINC;
  m_buffer[265] = PINC;
  m_buffer[266] = PINC;
  m_buffer[267] = PINC;
  m_buffer[268] = PINC;
  m_buffer[269] = PINC;
  m_buffer[270] = PINC;
  m_buffer[271] = PINC;
  m_buffer[272] = PINC;
  m_buffer[273] = PINC;
  m_buffer[274] = PINC;
  m_buffer[275] = PINC;
  m_buffer[276] = PINC;
  m_buffer[277] = PINC;
  m_buffer[278] = PINC;
  m_buffer[279] = PINC;
  m_buffer[280] = PINC;
  m_buffer[281] = PINC;
  m_buffer[282] = PINC;
  m_buffer[283] = PINC;
  m_buffer[284] = PINC;
  m_buffer[285] = PINC;
  m_buffer[286] = PINC;
  m_buffer[287] = PINC;
  m_buffer[288] = PINC;
  m_buffer[289] = PINC;
  m_buffer[290] = PINC;
  m_buffer[291] = PINC;
  m_buffer[292] = PINC;
  m_buffer[293] = PINC;
  m_buffer[294] = PINC;
  m_buffer[295] = PINC;
  m_buffer[296] = PINC;
  m_buffer[297] = PINC;
  m_buffer[298] = PINC;
  m_buffer[299] = PINC;
  m_buffer[300] = PINC;
  m_buffer[301] = PINC;
  m_buffer[302] = PINC;
  m_buffer[303] = PINC;
  m_buffer[304] = PINC;
  m_buffer[305] = PINC;
  m_buffer[306] = PINC;
  m_buffer[307] = PINC;
  m_buffer[308] = PINC;
  m_buffer[309] = PINC;
  m_buffer[310] = PINC;
  m_buffer[311] = PINC;
  m_buffer[312] = PINC;
  m_buffer[313] = PINC;
  m_buffer[314] = PINC;
  m_buffer[315] = PINC;
  m_buffer[316] = PINC;
  m_buffer[317] = PINC;
  m_buffer[318] = PINC;
  m_buffer[319] = PINC;
  m_buffer[320] = PINC;
  m_buffer[321] = PINC;
  m_buffer[322] = PINC;
  m_buffer[323] = PINC;
  m_buffer[324] = PINC;
  m_buffer[325] = PINC;
  m_buffer[326] = PINC;
  m_buffer[327] = PINC;
  m_buffer[328] = PINC;
  m_buffer[329] = PINC;
  m_buffer[330] = PINC;
  m_buffer[331] = PINC;
  m_buffer[332] = PINC;
  m_buffer[333] = PINC;
  m_buffer[334] = PINC;
  m_buffer[335] = PINC;
  m_buffer[336] = PINC;
  m_buffer[337] = PINC;
  m_buffer[338] = PINC;
  m_buffer[339] = PINC;
  m_buffer[340] = PINC;
  m_buffer[341] = PINC;
  m_buffer[342] = PINC;
  m_buffer[343] = PINC;
  m_buffer[344] = PINC;
  m_buffer[345] = PINC;
  m_buffer[346] = PINC;
  m_buffer[347] = PINC;
  m_buffer[348] = PINC;
  m_buffer[349] = PINC;
  m_buffer[350] = PINC;
  m_buffer[351] = PINC;
  m_buffer[352] = PINC;
  m_buffer[353] = PINC;
  m_buffer[354] = PINC;
  m_buffer[355] = PINC;
  m_buffer[356] = PINC;
  m_buffer[357] = PINC;
  m_buffer[358] = PINC;
  m_buffer[359] = PINC;
  m_buffer[360] = PINC;
  m_buffer[361] = PINC;
  m_buffer[362] = PINC;
  m_buffer[363] = PINC;
  m_buffer[364] = PINC;
  m_buffer[365] = PINC;
  m_buffer[366] = PINC;
  m_buffer[367] = PINC;
  m_buffer[368] = PINC;
  m_buffer[369] = PINC;
  m_buffer[370] = PINC;
  m_buffer[371] = PINC;
  m_buffer[372] = PINC;
  m_buffer[373] = PINC;
  m_buffer[374] = PINC;
  m_buffer[375] = PINC;
  m_buffer[376] = PINC;
  m_buffer[377] = PINC;
  m_buffer[378] = PINC;
  m_buffer[379] = PINC;
  m_buffer[380] = PINC;
  m_buffer[381] = PINC;
  m_buffer[382] = PINC;
  m_buffer[383] = PINC;
  m_buffer[384] = PINC;
  m_buffer[385] = PINC;
  m_buffer[386] = PINC;
  m_buffer[387] = PINC;
  m_buffer[388] = PINC;
  m_buffer[389] = PINC;
  m_buffer[390] = PINC;
  m_buffer[391] = PINC;
  m_buffer[392] = PINC;
  m_buffer[393] = PINC;
  m_buffer[394] = PINC;
  m_buffer[395] = PINC;
  m_buffer[396] = PINC;
  m_buffer[397] = PINC;
  m_buffer[398] = PINC;
  m_buffer[399] = PINC;
  m_buffer[400] = PINC;
  m_buffer[401] = PINC;
  m_buffer[402] = PINC;
  m_buffer[403] = PINC;
  m_buffer[404] = PINC;
  m_buffer[405] = PINC;
  m_buffer[406] = PINC;
  m_buffer[407] = PINC;
  m_buffer[408] = PINC;
  m_buffer[409] = PINC;
  m_buffer[410] = PINC;
  m_buffer[411] = PINC;
  m_buffer[412] = PINC;
  m_buffer[413] = PINC;
  m_buffer[414] = PINC;
  m_buffer[415] = PINC;
  m_buffer[416] = PINC;
  m_buffer[417] = PINC;
  m_buffer[418] = PINC;
  m_buffer[419] = PINC;
  m_buffer[420] = PINC;
  m_buffer[421] = PINC;
  m_buffer[422] = PINC;
  m_buffer[423] = PINC;
  m_buffer[424] = PINC;
  m_buffer[425] = PINC;
  m_buffer[426] = PINC;
  m_buffer[427] = PINC;
  m_buffer[428] = PINC;
  m_buffer[429] = PINC;
  m_buffer[430] = PINC;
  m_buffer[431] = PINC;
  m_buffer[432] = PINC;
  m_buffer[433] = PINC;
  m_buffer[434] = PINC;
  m_buffer[435] = PINC;
  m_buffer[436] = PINC;
  m_buffer[437] = PINC;
  m_buffer[438] = PINC;
  m_buffer[439] = PINC;
  m_buffer[440] = PINC;
  m_buffer[441] = PINC;
  m_buffer[442] = PINC;
  m_buffer[443] = PINC;
  m_buffer[444] = PINC;
  m_buffer[445] = PINC;
  m_buffer[446] = PINC;
  m_buffer[447] = PINC;
  m_buffer[448] = PINC;
  m_buffer[449] = PINC;
  m_buffer[450] = PINC;
  m_buffer[451] = PINC;
  m_buffer[452] = PINC;
  m_buffer[453] = PINC;
  m_buffer[454] = PINC;
  m_buffer[455] = PINC;
  m_buffer[456] = PINC;
  m_buffer[457] = PINC;
  m_buffer[458] = PINC;
  m_buffer[459] = PINC;
  m_buffer[460] = PINC;
  m_buffer[461] = PINC;
  m_buffer[462] = PINC;
  m_buffer[463] = PINC;
  m_buffer[464] = PINC;
  m_buffer[465] = PINC;
  m_buffer[466] = PINC;
  m_buffer[467] = PINC;
  m_buffer[468] = PINC;
  m_buffer[469] = PINC;
  m_buffer[470] = PINC;
  m_buffer[471] = PINC;
  m_buffer[472] = PINC;
  m_buffer[473] = PINC;
  m_buffer[474] = PINC;
  m_buffer[475] = PINC;
  m_buffer[476] = PINC;
  m_buffer[477] = PINC;
  m_buffer[478] = PINC;
  m_buffer[479] = PINC;
  m_buffer[480] = PINC;
  m_buffer[481] = PINC;
  m_buffer[482] = PINC;
  m_buffer[483] = PINC;
  m_buffer[484] = PINC;
  m_buffer[485] = PINC;
  m_buffer[486] = PINC;
  m_buffer[487] = PINC;
  m_buffer[488] = PINC;
  m_buffer[489] = PINC;
  m_buffer[490] = PINC;
  m_buffer[491] = PINC;
  m_buffer[492] = PINC;
  m_buffer[493] = PINC;
  m_buffer[494] = PINC;
  m_buffer[495] = PINC;
  m_buffer[496] = PINC;
  m_buffer[497] = PINC;
  m_buffer[498] = PINC;
  m_buffer[499] = PINC;
  m_buffer[500] = PINC;
  m_buffer[501] = PINC;
  m_buffer[502] = PINC;
  m_buffer[503] = PINC;
  m_buffer[504] = PINC;
  m_buffer[505] = PINC;
  m_buffer[506] = PINC;
  m_buffer[507] = PINC;
  m_buffer[508] = PINC;
  m_buffer[509] = PINC;
  m_buffer[510] = PINC;
  m_buffer[511] = PINC;
}