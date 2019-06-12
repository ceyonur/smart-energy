#include "ACS712.h"
char watt[5];
ACS712 sensor(ACS712_30A, A0);
unsigned long last_time =0;
unsigned long current_time =0;
float Wh =0 ;

void setup() {
  Serial.begin(115200);
  sensor.calibrate();
}

void loop() {
  float V = 230;
  float I = sensor.getCurrentAC();
  Serial.print("\nCurrent: ");
  Serial.println(I);
  Serial.print("\n");
  float P = V * I;
  last_time = current_time;
  current_time = millis();
  Wh = P *(( current_time - last_time) /3600000.0) ;
  dtostrf(Wh, 4, 2, watt);
  Serial.print("Power: ");
  Serial.write(watt);
  delay(10000);
}
