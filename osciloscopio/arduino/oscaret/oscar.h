#include <Arduino.h>
#include <SPI.h>

#ifndef OSCAR_h
#define OSCAR_h

class Oscar {
  public:
    enum AD_DC {DC, AC};
    enum MODE {FS5MSPS, FS2MSPS, FS1MSPS, FS500KSPS, FS250KSPS, FS125KSPS, FS50KSPS, FS25KSPS};
    enum RELAY {ACDC = 2, SEN1, SEN2};
    enum SEN_1 {S_10MV, S_1V};
    enum SEN_2 {X1, X5};
    
    static const char COMMAND_END = '\n';
    static const byte MAX_COMMAND = 16;
    
    static const byte PGA_GAIN_CMD = 0x40;
    static const byte PGA_CS = 9;
    
    Oscar();
    
    void add_char_command(char c);
    void aquire_and_send();
    void aquire_and_send_5Msps();
    void aquire_and_send_2Msps();
    void aquire_and_send_1Msps();
    void aquire_and_send_500ksps();
    void aquire_and_send_250ksps();
    void aquire_and_send_125ksps();
    void aquire_and_send_50ksps();
    void aquire_and_send_25ksps();
    char get_command();
    void reset_command();
    void set_acdc();
    void set_fs();
    void set_sen1();
    void set_sen2();
    void setup();
  private:
    char m_command[MAX_COMMAND];
    byte m_commandCount;
    byte m_mode;
    
    double get_float_from_command();
    int get_int_from_command();
    void pinc_setup();
    void rele_setup();
    void send_buffer();
    void set_ca3306_clock(uint32_t fs);
};

#endif
