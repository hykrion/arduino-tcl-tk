#include <Arduino.h>
#ifndef TEA5767_h
#define TEA5767_h

// TEA bits
#define TEA_ADDR    0x60
#define TEA_MUTE    0x80
#define TEA_MON_STE 0x08
#define TEA_HLSI    0X10

#define TEA_I2C_BUF 5
#define TEA_MAX_COMMAND 16
#define TEA_COMMAND_END '\n'

#define TEA_PLL_LSI 0
#define TEA_PLL_HSI 1

// MCP41010
#define MCP41010_CS 10
#define MCP41010_CMD_WRITE_DATA 0x11

/**
  Frequency (Hz)
*/
#define TEA_F_IF  225000
#define TEA_F_REF 32768

class TEA5767
{
  private:
    byte m_I2CWriteBuffer[TEA_I2C_BUF];
    byte m_I2CReadBuffer[TEA_I2C_BUF];
    byte m_I2CReadReady;
    char m_command[TEA_MAX_COMMAND];
    byte m_commandCount;
    byte m_pllHLSI;
    
    void sendI2CData();
    void setPllHLSI(byte type);
    byte getPllHLSI();
  public:
    TEA5767();
    void setFrequency();
    void setMute();
    void setHighFidelity();
    void setPllHLSI();
    void setVolume();
    
    void setI2CAvailable(byte value);
    byte getI2CAvailable();
    void readData();
    int getSignalLevel();
    int getStereo();
    
    void addCharCommand(char c);
    void resetCommand();
    void resetI2CRead();
    void resetI2CWrite();
    char getCommand();
};

#endif
