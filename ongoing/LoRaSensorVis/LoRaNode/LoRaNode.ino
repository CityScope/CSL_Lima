/** 
 *  Import the necessary libraries
 */
#include <TheThingsNetwork.h>
#include <SoftwareSerial.h>
#include <DHT.h>
#include <DHT_U.h>
#include <Adafruit_GPS.h>
#include <LoraMessage.h>

/**
 * Application information requiered to connect to TTN
 */
const char *appEui = "****************";
const char *appKey = "********************************";

/** 
 *  Wiring:
 *  Connect the DHT Shield Power pin to 3.3V
 *  Connect the DHT Shield Ground pin to ground
 *  Connect the DHT Shield D4 pin to digital pin 2
 *  Connect the GPS Power pin to 3.3V
 *  Connect the GPS Ground pin to ground
 *  Connect the GPS TX (transmit) pin to Digital 8
 *  Connect the GPS RX (receive) pin to Digital 7
 */

/**
 * Customize Serial1, TTN's frequency plan and GPS displayable data
 */
#define loraSerial Serial1
#define freqPlan TTN_FP_EU868
#define GPSECHO  false

/**
 * Variable initialization
 */
TheThingsNetwork ttn(loraSerial, Serial, freqPlan);
DHT dht(2, DHT22);
SoftwareSerial mySerial(8, 7);
Adafruit_GPS GPS(&mySerial);

/**
 * Start the Serials with a certain baud rate
 * Try to establish connection to TTN
 * Begin reading data from the sensors
 */
void setup() {
  Serial.begin(115200);
  loraSerial.begin(57600);

  while (!Serial && millis() < 10000);
  Serial.println("LoRa Node!");

  Serial.println("-- STATUS");
  ttn.showStatus();

  Serial.println("-- JOIN");
  ttn.join(appEui, appKey);

  dht.begin();

  GPS.begin(9600); 
  GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCGGA);
  GPS.sendCommand(PMTK_SET_NMEA_UPDATE_1HZ);
  GPS.sendCommand(PGCMD_ANTENNA);

  delay(1000);
  mySerial.println(PMTK_Q_RELEASE);
}

uint32_t timer = millis();

/**
 * Continuosly check for new GPS and sensor data
 * Transform the data into bytes and store it in a payload
 * Every 10 seconds, send the byte payload to TTN
 */
void loop() {
  char c = GPS.read();
  if ((c) && (GPSECHO))
    Serial.write(c);

  if (GPS.newNMEAreceived()) {
    if (!GPS.parse(GPS.lastNMEA()))
      return;
  }

  if (timer > millis())  timer = millis();

  if (millis() - timer > 10000) {
    timer = millis();

    LoraMessage message;

    message.addLatLng(GPS.latitudeDegrees, GPS.longitudeDegrees);
    message.addTemperature(dht.readTemperature(false));
    message.addHumidity(dht.readHumidity(false));

    ttn.sendBytes(message.getBytes(), message.getLength());
  }
}
