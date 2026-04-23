# 🌱 Plant Water App

iOS app using CoreBluetooth with an Arduino BLE peripheral, integrated with a GraphQL backend for storing sensor readings and visualized using Swift Charts.

## ✨ Features

- CoreBluetooth central implementation (iOS)
- Arduino BLE peripheral
- Real-time moisture readings via BLE
- GraphQL backend for storing and fetching readings
- SwiftUI + Swift Charts for data visualization
- WeatherKit integration for environmental context

## 🗂 Project Structure

- `PlantWaterApp/` – iOS application
- `Arduino/` – BLE peripheral (soil sensor)

## 📡 Bluetooth Overview

The iOS app connects to a BLE peripheral that simulates a soil moisture sensor.  
Sensor values are transmitted via characteristic notifications and processed in real time.

## 🧠 GraphQL Integration

GraphQL is used to:
- Save sensor readings
- Fetch historical data
- Avoid over-fetching and support scalable data access

Backend is implemented using Cloudflare Workers with a D1 SQL database.

## 🎯 Purpose

This project demonstrates:
- BLE communication (CoreBluetooth)
- Hardware/software interaction (Arduino + iOS)
- Modern iOS MVVM architecture (SwiftUI, dependency injection, protocol based services)
- Backend integration using GraphQL

## ⚠️ WeatherKit Note

WeatherKit requires an Apple Developer account and proper entitlements to function.

If unavailable, the app will still run and demonstrate:
- BLE communication
- GraphQL data flow
- Chart visualization

Weather data will simply not be displayed.
