#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

const int soilSensorPin = A0;

#define SERVICE_UUID        "180C"
#define CHARACTERISTIC_UUID "1234"

BLECharacteristic* soilCharacteristic;
bool deviceConnected = false;

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("Central connected");
  }

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("Central disconnected");
    BLEDevice::startAdvertising();
  }
};

void setup() {
  Serial.begin(115200);
  delay(1000);

  analogReadResolution(12);
  pinMode(soilSensorPin, INPUT);

  BLEDevice::init("SoilSensor");

  BLEServer* pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService* pService = pServer->createService(SERVICE_UUID);

  soilCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_NOTIFY
  );

  soilCharacteristic->addDescriptor(new BLE2902());

  uint16_t initialValue = 0;
  soilCharacteristic->setValue((uint8_t*)&initialValue, sizeof(initialValue));

  pService->start();

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);

  BLEDevice::startAdvertising();

  Serial.println("BLE soil sensor advertising as 'SoilSensor'");
}

void loop() {
  int raw = analogRead(soilSensorPin);

  uint16_t soilValue = (uint16_t)raw;

  soilCharacteristic->setValue((uint8_t*)&soilValue, sizeof(soilValue));

  if (deviceConnected) {
    soilCharacteristic->notify();
  }

  Serial.print("Soil raw value: ");
  Serial.println(soilValue);

  delay(1000);
}
