// Arduino tiene un LED conectado en su pin 13
#define LED 13

/*
Iniciar Arduino
*/
void setup()
{
  // Iniciar el puerto serie
  Serial.begin(9600);
  delay(100);
  // Configurar el pin 13 como salida
  pinMode(LED, OUTPUT);
}

/*
Bucle. Iremos leyendo el puerto serie y si nos envian una 'H'
encenderemos el LED. Si nos envian una 'L' lo apagaremos
*/
void loop()
{
  char command = Serial.read();
  
  if(command == 'H')
    digitalWrite(LED, HIGH);
  else if(command == 'L')
    digitalWrite(LED, LOW);
}
