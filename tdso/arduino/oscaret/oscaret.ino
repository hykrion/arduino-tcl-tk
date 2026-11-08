#include "oscar.h"

Oscar osc;

// ----------------------------------------------
// ----------------------------------------------
void setup()
{
  Serial.begin(115200);
  delay(100);
  osc.setup();
}

void loop()
{
  while (Serial.available())  
  {
    char c = Serial.read();

    if (c == Oscar::COMMAND_END)
    {
      char cmd = osc.get_command();

      switch(cmd)
      {
        case 'a':
          osc.set_acdc();
          break;
        case 'f':
          osc.set_fs();
          break;
        case 'l':
          osc.set_trigger();
          break;
        case 't':
          osc.set_trigger_slope();
          break;
        case 's':
          osc.set_sen1();
          break;
        case 'x':
          osc.set_sen2();
          break;
      }
      osc.reset_command();
    }
    else
    {
      osc.add_char_command(c);
    }
  }

  osc.aquire_and_send();  
}
//