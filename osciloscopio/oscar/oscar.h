#include <Arduino.h>

#ifndef OSCAR_h
#define OSCAR_h

class Oscar {
  public:
    static const byte MAX_COMMAND = 16;
    static const char COMMAND_END = '\n';
    static volatile byte bufferFull;

    Oscar();
    void setup();
    char getCommand();
    void reset_command();
    void addCharCommand(char c);
    
    void sendBuffer();
    
    void setPrescaler();
    void setACDC();
    void setGain();

    void init_ks();
    void init_pwm();
  private:
    char m_command[MAX_COMMAND];
    byte m_commandCount;
    
    // Command
    double getFloatFromCommand();
    int getIntFromCommand();

    // Prescaler
    byte getPS();

    // AC/DC
    char getACDC();
    void setAC();
    void setDC();

    // Gain    
    void setGainX016();
    void setGainX02();
    void setGainX05();
    void setGainX10();
    void setGainX20();
    void setGainX60();
    void setGainX70();
};

#endif
