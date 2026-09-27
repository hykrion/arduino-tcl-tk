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
  if(Oscar::bufferFull)
  {
    osc.sendBuffer();
  }
  
  if (Serial.available())  
  {
    char c = Serial.read();

    if (c == Oscar::COMMAND_END)
    {
      char cmd = osc.getCommand();

      switch(cmd)
      {
        case 'p':
          osc.setPrescaler();
          break;
        case 'g':
          osc.setGain();
          break;
        case 'a':
          osc.setACDC();
          break;
      }
      osc.reset_command();
    }
    else
    {
      osc.addCharCommand(c);
    }
  }
}
