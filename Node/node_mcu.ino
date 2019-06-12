#include <ESP8266WiFi.h>
#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"
#define WLAN_SSID       "KS2TI9D"
#define WLAN_PASS       "desktopnebih"
#define AIO_SERVER      "io.adafruit.com"
#define AIO_SERVERPORT  1883
#define AIO_USERNAME    "nbasaran"
#define AIO_KEY         "862a17701f6e43549ce85d8e6ced6cfb"

WiFiClient client;
String deviceName = "smartenergy13";

char watt[5];
Adafruit_MQTT_Client mqtt(&client, AIO_SERVER, AIO_SERVERPORT, AIO_USERNAME, AIO_KEY);
Adafruit_MQTT_Publish kws = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/kws");
Adafruit_MQTT_Publish power = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/power");
void MQTT_connect();

void setup() {
  Serial.begin(115200);
  delay(10);
  Serial.println(F("Adafruit MQTT demo"));

  // Connect to WiFi access point.
  Serial.println(); Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WLAN_SSID);

  WiFi.begin(WLAN_SSID, WLAN_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  Serial.println("WiFi connected");
  Serial.println("IP address: "); Serial.println(WiFi.localIP());
}

void loop() {
  MQTT_connect();

  int i=0;
  float watt1;
  if(Serial.available() > 0 ){
    delay(100);
    while(Serial.available() && i<5) {
      watt[i++] = Serial.read();
    }
    watt[i++]='\0';
  }

  watt1 = atof(watt);
  char buffer[60];
  String data = "{\"kws\":";
  dtostrf(watt1, 1, 2, buffer);
  data += buffer;
  data += ",\"deviceName\":";
  data += '"' + deviceName + '"';
  data += "}";
  char dataBuf[60];
  data.toCharArray(dataBuf, 60);

  Serial.print("\nSending Power val ");
  Serial.println(watt);
  Serial.print("\nWatt1:");
  Serial.println(watt1);
  Serial.print("...");

  if (!kws.publish(dataBuf)) {
    Serial.println(F("Failed"));
  } else {
    Serial.println(F("OK!"));
  }

  if (! power.publish(watt1)) {
    Serial.println(F("Failed"));
  } else {
    Serial.println(F("OK!"));
  }
  delay(5000);
}

void MQTT_connect() {
  int8_t ret;
  if (mqtt.connected()) {
    return;
  }
  Serial.print("Connecting to MQTT... ");
  uint8_t retries = 3;
  while ((ret = mqtt.connect()) != 0) {
    Serial.println(mqtt.connectErrorString(ret));
    Serial.println("Retrying MQTT connection in 5 seconds...");
    mqtt.disconnect();
    delay(5000);
    retries--;
    if (retries == 0) {
      while (1);
    }
  }
  Serial.println("MQTT Connected!");
}
