# Arduino BLE Soil Sensor

This Arduino sketch implements a Bluetooth Low Energy (BLE) peripheral that transmits soil moisture readings to an iOS app.

## Overview

- Acts as a BLE peripheral  
- Advertises a custom service  
- Sends moisture readings via characteristic notifications  
- Designed to be consumed by the iOS CoreBluetooth central app  

## Hardware

Tested with:
- Arduino Nano ESP32 (BLE capable)

## Behavior

- Emits periodic moisture values  
- Values are transmitted to the connected iOS device  
- Supports real-time updates via BLE notifications  

## iOS Integration

The iOS app:
- Scans for the peripheral  
- Connects automatically  
- Subscribes to the moisture characteristic  
- Updates UI and GraphQL backend in real time  

## Notes

- Demonstrates BLE communication flow end to end  
- Can be extended to integrate with physical soil moisture sensors via analog input  