#include "OSCAR.h"

// Cabecera frames
static const byte FRAME_HEADER[] = { 0xA5, 0x5A, 0xC3, 0x3C };

// PWM
static const byte PWM_NEG_VCC = 3;
static const byte PWM_CAL_PROBE = 5;

// Reles
static const byte K_A = 6;
static const byte K_B = 7;
static const byte K_C = 8;
static const byte K_D = 9;

static const byte K_E = 10;
static const byte K_F = 11;
static const byte K_G = 12;
static const byte K_H = 4;

// Diferentes preescalados
static const byte PS_128 = B00000111;
static const byte PS_64 = B00000110;
static const byte PS_32 = B00000101;
static const byte PS_16 = B00000100;
static const byte PS_8 = B00000011;

// Configuracion base del ADCSRA:
// -habilitar el ADC sin empezar la conversión
// -usar free running
// -habilitar interrupciones
// -sin preescalado (PS_2)
static const byte ADCSRA_BASE = B10101000;

static volatile byte currentPrescaler = PS_128;
static volatile byte triggerLevel = 0;
static volatile bool triggerArmed = false;
static volatile bool triggerRising = true;
static volatile bool triggerWaiting = false;

// WIP 512 vs 1024
static const int BUFFER_SIZE = 1024;
static volatile byte buffer[BUFFER_SIZE];
static volatile int bufferIndex;
volatile byte Oscar::bufferFull = false;

ISR(ADC_vect)
{
  byte sample = ADCH;

  if (triggerWaiting)
  {
    if (triggerRising ? sample < triggerLevel : sample > triggerLevel)
    {
      // Conservar la muestra real inmediatamente anterior al cruce.
      buffer[0] = sample;
      triggerArmed = true;
    }
    else if (triggerArmed)
    {
      // Muestra 0: predisparo; muestra 1: cruce; 1022 muestras restantes.
      bufferIndex = 1;
      triggerWaiting = false;
    }
  }

  if (!triggerWaiting)
  {
    buffer[bufferIndex++] = sample;

    if (bufferIndex == BUFFER_SIZE)
    {
      bufferIndex = 0;
      Oscar::bufferFull = true;
      ADCSRA &= ~_BV(ADEN);
    }
  }
}

static void
init_buffer()
{
  bufferIndex = 0;
  Oscar::bufferFull = false;
  triggerArmed = false;
  triggerWaiting = (triggerLevel != 0);
  memset((byte*)buffer, 0, BUFFER_SIZE);
}

static void
init_adc()
{
  // Eliminar posibles ruidos deshabilitando el digital input buffer
  DIDR0 = B00111111;
  // Voltaje de referencia AVcc con condensador en AREF,
  // usando 8bits (valor ADCH), ADC0 (A0)
  ADMUX = B01100000;
  // Inicialmente tenemos la menor frecuencia de muestreo
  ADCSRA = ADCSRA_BASE | PS_128;
  // Trigger: free running
  ADCSRB = B00000000;
  // Empezar las conversiones
  ADCSRA |= _BV(ADSC);
}

// ------------------------------------------------------------------
// ------------------------------------------------------------------
Oscar::Oscar()
{
  reset_command();
  init_buffer();
}

void Oscar::setup()
{
  init_ks();
  init_pwm();
  delay(1500);
  digitalWrite(K_A, LOW);
  delay(100);
  init_adc();
}

char Oscar::getCommand()
{
  return m_command[0];
}

void Oscar::reset_command()
{
  memset(m_command, '\0', MAX_COMMAND);
  m_commandCount = 0;
}

void Oscar::addCharCommand(char c)
{
  if (c != '\r' && c != '\n')
  {
    m_command[m_commandCount] = c;
    m_commandCount = (m_commandCount + 1) % MAX_COMMAND;
  }
}

// Commands
void Oscar::setPrescaler()
{
  byte savedSREG = SREG;
  noInterrupts();
  currentPrescaler = getPS();
  if (!Oscar::bufferFull)
  {
    if (triggerLevel != 0)
    {
      // Descartar la captura parcial y esperar un nuevo flanco.
      ADCSRA &= ~_BV(ADEN);
      init_buffer();
      ADCSRA = ADCSRA_BASE | currentPrescaler | _BV(ADIF) | _BV(ADSC);
    }
    else
      ADCSRA = ADCSRA_BASE | currentPrescaler | _BV(ADSC);
  }
  SREG = savedSREG;
}

// ---------------------------------------------
void Oscar::setTrigger()
{
  // Validar antes de modificar la adquisicion: l0 ... l255.
  int level = 0;
  bool valid = (m_commandCount >= 2 && m_commandCount <= 4);
  for (byte i = 1; i < m_commandCount && valid; ++i)
  {
    char c = m_command[i];
    if (c < '0' || c > '9')
      valid = false;
    else
      level = level * 10 + (c - '0');
  }

  if (valid && level <= 255)
  {
    byte savedSREG = SREG;
    noInterrupts();
    ADCSRA &= ~_BV(ADEN);
    triggerLevel = (byte)level;
    init_buffer();
    // ADIF se borra escribiendo un uno: descartar interrupciones pendientes.
    ADCSRA = ADCSRA_BASE | currentPrescaler | _BV(ADIF) | _BV(ADSC);
    SREG = savedSREG;
  }
  return;
}

// ---------------------------------------------
void Oscar::setTriggerSlope()
{
  // s1: subida (predeterminado); s0: bajada. No habilita el trigger.
  if (m_commandCount == 2 && (m_command[1] == '0' || m_command[1] == '1'))
  {
    byte savedSREG = SREG;
    noInterrupts();
    ADCSRA &= ~_BV(ADEN);
    triggerRising = (m_command[1] == '1');
    init_buffer();
    ADCSRA = ADCSRA_BASE | currentPrescaler | _BV(ADIF) | _BV(ADSC);
    SREG = savedSREG;
  }
  return;
}

// ---------------------------------------------
void Oscar::sendBuffer()
{
  // Cabecera de la trama
  Serial.write(FRAME_HEADER, sizeof(FRAME_HEADER));
  
  // El ADC ya está detenido así que el buffer no cambia
  Serial.write((byte*)buffer, BUFFER_SIZE);
  Serial.flush();

  //noInterrupts();

  init_buffer();
  ADCSRA = ADCSRA_BASE | currentPrescaler | _BV(ADSC);

  //interrupts();
}

void Oscar::setACDC()
{
  char opt = getACDC();

  switch (opt)
  {
    case 'a':
      setAC();
      break;
    case 'd':
      setDC();
      break;
  }
}

void Oscar::init_ks()
{
  // Por defecto, todos en reposo (son activos a nivel bajo)
  for(int i = K_A; i < K_G; i++)
  {
    pinMode(i, OUTPUT);
    digitalWrite(i, HIGH);
  }
  pinMode(K_G, OUTPUT);
  digitalWrite(K_G, HIGH);
  pinMode(K_H, OUTPUT);
  digitalWrite(K_H, HIGH);
}

void Oscar::init_pwm()
{
  pinMode(PWM_NEG_VCC, OUTPUT);
  pinMode(PWM_CAL_PROBE, OUTPUT);

  analogWrite(PWM_NEG_VCC, 127);
  analogWrite(PWM_CAL_PROBE, 127);
}

void Oscar::setGain()
{
  int gain = getIntFromCommand();

  switch (gain)
  {
    case 1:
      setGainX016();
      break;
    case 2:
      setGainX02();
      break;
    case 3:
      setGainX05();
      break;
    case 4:
      setGainX10();
      break;
    case 5:
      setGainX20();
      break;
    case 6:
      setGainX60();
      break;
    case 7:
      setGainX70();
      break;
  }
}

/** +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Private
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
double Oscar::getFloatFromCommand()
{
  char cmd[MAX_COMMAND] = {'\0'};
  
  for(int i = 0; i < MAX_COMMAND - 1; i++)
    cmd[i] = m_command[i + 1];
  
  return atof(cmd);
}

int Oscar::getIntFromCommand()
{
  char cmd[MAX_COMMAND] = {'\0'};
  
  for(int i = 0; i < MAX_COMMAND - 1; i++)
    cmd[i] = m_command[i + 1];
  
  return atoi(cmd);
}

byte Oscar::getPS()
{
  byte result = PS_128;
  
  int ps = getIntFromCommand();

  switch (ps)
  {
    case 128:
      result = PS_128;
      break;
    case 64:
      result = PS_64;
      break;
    case 32:
      result = PS_32;
      break;
    case 16:
      result = PS_16;
      break;
    case 8:
      result = PS_8;
      break;
  }
  
  return result;
}

char Oscar::getACDC()
{
  return m_command[1];
}

void Oscar::setAC()
{
  digitalWrite(K_B, HIGH);
  digitalWrite(K_G, HIGH);
}

void Oscar::setDC()
{
  digitalWrite(K_B, LOW);
  digitalWrite(K_G, LOW);
}

void Oscar::setGainX016()
{
  digitalWrite(K_C, HIGH);
  digitalWrite(K_D, HIGH);

  digitalWrite(K_E, HIGH);
  digitalWrite(K_F, HIGH);
}

void Oscar::setGainX02()
{
  digitalWrite(K_C, HIGH);
  digitalWrite(K_D, LOW);

  digitalWrite(K_E, HIGH);
  digitalWrite(K_F, HIGH);
}

void Oscar::setGainX05()
{
  digitalWrite(K_C, LOW);
  digitalWrite(K_D, HIGH);

  digitalWrite(K_E, HIGH);
  digitalWrite(K_F, HIGH);
}

void Oscar::setGainX10()
{
  digitalWrite(K_C, LOW);
  digitalWrite(K_D, LOW);

  digitalWrite(K_E, HIGH);
  digitalWrite(K_F, HIGH);
}

void Oscar::setGainX20()
{
  digitalWrite(K_C, LOW);
  digitalWrite(K_D, LOW);

  digitalWrite(K_E, HIGH);
  digitalWrite(K_F, LOW);
}

void Oscar::setGainX60()
{
  digitalWrite(K_C, LOW);
  digitalWrite(K_D, LOW);

  digitalWrite(K_E, LOW);
  digitalWrite(K_F, HIGH);
}

void Oscar::setGainX70()
{
  digitalWrite(K_C, LOW);
  digitalWrite(K_D, LOW);

  digitalWrite(K_E, LOW);
  digitalWrite(K_F, LOW);
}
