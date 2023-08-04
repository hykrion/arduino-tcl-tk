#include <tea5767.h>

// IDE 1.0 - BEG
//#include <Wire.h>
//#include <SPI.h>
// IDE 1.0 - END

TEA5767 radio;

void setup()
{
  Serial.begin(9600);
  delay(100);
}

void loop()
{
  // Get command and execute it
  while (Serial.available())  
  {
    char c = Serial.read();

    if (c == TEA_COMMAND_END)
    {
      char cmd = radio.getCommand();

      switch(cmd)
      {
        // Frequency
        case 'f':
          radio.setFrequency();
          break;
        // Mute
        case 'm':
          radio.setMute();
          break;
        // Stereo/mono
        case 'h':
          radio.setHighFidelity();
          break;
        // Read chip data: signal level, mono/stereo, etc.
        case 'd':
          radio.readData();
          break;
        case 'p':
          radio.setPllHLSI();
          break;
        case 'v':
          radio.setVolume();
          break;
        // DEBUG
        case 'x':
          radio.resetI2CWrite();
          break;
      }
      radio.resetCommand();
    }
    else
    {
      radio.addCharCommand(c);
    }
  }
  
  // If we have read any data, send it to the computer
  if(radio.getI2CAvailable())
  {
    // Get chip data
    int stereoSignalLevel = radio.getStereo();
    int level = radio.getSignalLevel();
    // Send data to PC
    Serial.print("STE");
    Serial.print(stereoSignalLevel);
    Serial.print(":LEV");
    Serial.print(level);
    Serial.println(":");
    radio.setI2CAvailable(0);
  }
}
