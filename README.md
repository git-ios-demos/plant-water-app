# 🌱 Plant Water App

iOS app using CoreBluetooth with an Arduino BLE peripheral, integrated with a GraphQL backend for storing soil moisture sensor readings, WeatherKit forecasts, and visualizations using Swift Charts.

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
- `workers/` – Cloudflare Workers GraphQL backend with D1 database

## 📡 Bluetooth Overview

The iOS app connects to a BLE soil moisture sensor.  
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
- Modern iOS MVVM architecture (SwiftUI, dependency injection, protocol-based services)
- Backend integration using GraphQL

## ⚙️ Engineering Notes

- Built with Swift 6 and modern concurrency using `async/await`
- Strict concurrency checking enabled (`Complete`)
- Uses SwiftLint for consistent code style and quality
- Includes unit tests using Swift Testing framework
- Supports manual entry of soil readings for demo purposes when hardware is unavailable
- Primary deployment target is iOS 26, but can be adjusted to iOS 18 if needed

## ⚠️ WeatherKit Note

WeatherKit requires an Apple Developer account and proper entitlements to function.

If unavailable, the app will still run and demonstrate:
- Manual sensor reading input
- GraphQL data flow

Weather data will simply not be displayed.
