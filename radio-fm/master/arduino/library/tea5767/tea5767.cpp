#include <TEA5767.h>

#include <Wire.h>
#include <SPI.h>

/** -------------------------------------------------------
  @brief  Configure the PLL according to whether it is
          high / low injection
 ------------------------------------------------------- */
static unsigned int pllHLSI(double fre, byte type)
{
  unsigned int result = 0;
  
  if(type == TEA_PLL_HSI)
    result = 4 * (fre * 1000000 + TEA_F_IF) / TEA_F_REF;
  else
    result = 4 * (fre * 1000000 - TEA_F_IF) / TEA_F_REF;
  
  return result;
}

/** -------------------------------------------------------
  @brief  Get the high side of PLL
 ------------------------------------------------------- */
static byte pllHigh(double frequency, byte type)
{
  unsigned int pll = pllHLSI(frequency, type);
   
  return ((pll >> 8) & 0x3F);
}

/** -------------------------------------------------------
  @brief  Get the bottom side of PLL
  ------------------------------------------------------- */
static byte pllLow(double frequency, byte type)
{
  unsigned int pll = pllHLSI(frequency, type);
   
  return (pll & 0XFF);
}

/** -------------------------------------------------------
  @brief  Get frequency from the command
 ------------------------------------------------------- */
static double getFloatFromCommand(char* charFloat)
{
  char cmd[TEA_MAX_COMMAND] = {'\0'};
  
  for(int i = 0; i < TEA_MAX_COMMAND - 1; i++)
    cmd[i] = charFloat[i + 1];
  
  return atof(cmd);
}

/** -------------------------------------------------------
 @brief Many commands are true/false
 
 @param c     command parameter
 @param cTrue char for true
  ------------------------------------------------------ */
static boolean boolCommand(char c, char cTrue)
{
  boolean result = false;
  
  if (c == cTrue)
    result = true;
  
  return result;
}

/** +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Private
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/** -------------------------------------------------------
  @brief  Send data to radio
  ------------------------------------------------------ */
void TEA5767::sendI2CData()
{
  Wire.beginTransmission(TEA_ADDR);
   
  for(int i = 0; i < TEA_I2C_BUF; i++)
    Wire.write(m_I2CWriteBuffer[i]);

  Wire.endTransmission();
}

/** -------------------------------------------------------
  @brief  Using High/Low Side Injection
  
  @param  type: TEA_PLL_LSI / TEA_PLL_HSI
  ------------------------------------------------------ */
void TEA5767::setPllHLSI(byte type)
{
  m_pllHLSI = type;
}

/** -------------------------------------------------------
  @brief  Obtener el tipo de inyeccion PLL
  ------------------------------------------------------ */
byte TEA5767::getPllHLSI()
{
  return m_pllHLSI;
}

/** +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Public
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/** -------------------------------------------------------
 ------------------------------------------------------- */
TEA5767::TEA5767()
{
  setPllHLSI(TEA_PLL_HSI);
  
  resetI2CRead();
  resetI2CWrite();
  resetCommand();
  
  Wire.begin();
}


/** -------------------------------------------------------
  @brief  Select station
  ------------------------------------------------------ */
void TEA5767::setFrequency()
{
  double fre = getFloatFromCommand(m_command);
  
  m_I2CWriteBuffer[0] &= 0xC0;
  m_I2CWriteBuffer[0] |= pllHigh(fre, m_pllHLSI);
  m_I2CWriteBuffer[1] = pllLow(fre, m_pllHLSI);
   
  sendI2CData(); 
}

/** -------------------------------------------------------
 @brief Mute/listen to the radio
 
 command: m[yn] yes,no
  ------------------------------------------------------ */
void TEA5767::setMute()
{
  boolean result = boolCommand(m_command[1], 'y');
  
  if(result)
    m_I2CWriteBuffer[0] |= TEA_MUTE;
  else
    m_I2CWriteBuffer[0] &= ~TEA_MUTE;
  
  sendI2CData();
}

/** -------------------------------------------------------
 @brief Stereo / Mono

 command: h[yn] yes, no
  ------------------------------------------------------ */
void TEA5767::setHighFidelity()
{
  boolean result = boolCommand(m_command[1], 'y');
  
  if(result)
    m_I2CWriteBuffer[2] &= ~TEA_MON_STE;
  else    
    m_I2CWriteBuffer[2] |= TEA_MON_STE;
  
  sendI2CData();
}

/** -------------------------------------------------------
 @brief High / Low Side Injection

 command: p[hl] yes, no
  ------------------------------------------------------ */
void TEA5767::setPllHLSI()
{
  boolean result = boolCommand(m_command[1], 'h');
  
  if(result)
  {
    setPllHLSI(TEA_PLL_HSI);
    m_I2CWriteBuffer[2] |= TEA_HLSI;
  }
  else
  {
    setPllHLSI(TEA_PLL_LSI);
    m_I2CWriteBuffer[2] &= ~TEA_HLSI;
  }
  
  sendI2CData();
}

/** -------------------------------------------------------
  @brief  Poner volumen.

          El TEA5767 no dispone de control digital de volumen,
          pero suponemos que has utilizado el mcp41010 para ello.
          Este chip lo controlamos mediante SPI
  ------------------------------------------------------ */
void TEA5767::setVolume()
{
  double vol = getFloatFromCommand(m_command);
  int val = (vol * 255) / 100;

  // TODO
  // -circuito breakboard con led para ver que pasa
  //m_volume.setPercent(val);
  
  SPI.begin();
  digitalWrite(MCP41010_CS, LOW);
  SPI.transfer(MCP41010_CMD_WRITE_DATA);
  SPI.transfer(val);
  digitalWrite(MCP41010_CS, HIGH);
  SPI.end();
  
}

/** -------------------------------------------------------
 @brief Flag que indica si el TEA5767 nos ha enviado los
        datos que hemos solicitado
  ------------------------------------------------------ */
void TEA5767::setI2CAvailable(byte value)
{
  m_I2CReadReady = value;
}

/** -------------------------------------------------------
 @brief Get TEA5767 data
  ------------------------------------------------------ */
byte TEA5767::getI2CAvailable()
{
  return m_I2CReadReady;
}

/** -------------------------------------------------------
 @brief Read data: signal type (mono/stereo), signal level,
        etc...
        8.5 Reading data
  ------------------------------------------------------ */
void TEA5767::readData()
{
  resetCommand();
  
  Wire.requestFrom(TEA_ADDR, TEA_I2C_BUF);

  unsigned long time = millis();
  while(Wire.available() < 5 && (millis() - time < 5));
  
  int i;
  for(i = 0; i < 5; i++)
    m_I2CReadBuffer[i] = Wire.read();
  setI2CAvailable(1);
}

/** -------------------------------------------------------
 @brief Read signal level
        8.5 Reading data: 4th byte [7:4]bits
  ------------------------------------------------------ */
int TEA5767::getSignalLevel()
{
  int result = 0;
  
  if(m_I2CReadReady)
  {
    byte data = m_I2CReadBuffer[3];
    result = (data >> 4) & 0x0F;
  }
  
  return result;
}

/** -------------------------------------------------------
 @brief Read if we have a stereo or mono signal
        8.5 Reading data: 3th byte [7]bit
  ------------------------------------------------------ */
int TEA5767::getStereo()
{
  int result = -1;
  
  if(m_I2CReadReady)
  {
    byte data = m_I2CWriteBuffer[2];
    result = (data >> 7) & 0x01;
  }
  
  return result;
}

/** -------------------------------------------------------
  @brief  Creating the command
  ------------------------------------------------------ */
void TEA5767::addCharCommand(char c)
{
  if (c != '\r' && c != '\n')
  {
    m_command[m_commandCount] = c;
    m_commandCount = (m_commandCount + 1) % TEA_MAX_COMMAND;
  }
}

/** -------------------------------------------------------
  @brief  Reset command buffer
  ------------------------------------------------------ */
void TEA5767::resetCommand()
{
  memset(m_command, '\0', TEA_MAX_COMMAND);
  m_commandCount = 0;
}

/** -------------------------------------------------------
  @brief  Reset read buffer
  ------------------------------------------------------ */
void TEA5767::resetI2CRead()
{
  memset(m_I2CReadBuffer, 0, TEA_I2C_BUF);
  m_I2CReadReady = 0;
}

/** -------------------------------------------------------
  @brief  This is a basic setup:
          -not silenced, manual search
          -seek up, low signal, high injection and mono
          -European frequencies, xtal 32768
  ------------------------------------------------------ */
void TEA5767::resetI2CWrite()
{
  m_I2CWriteBuffer[0] = 0x00;
  m_I2CWriteBuffer[1] = 0x00;
  m_I2CWriteBuffer[2] = 0xB8;
  m_I2CWriteBuffer[3] = 0x10;
  m_I2CWriteBuffer[4] = 0x00;
  m_I2CReadReady = 0;
}
/** -------------------------------------------------------
  @brief  Return the command in question
  ------------------------------------------------------ */
char TEA5767::getCommand()
{
  return m_command[0];
}
