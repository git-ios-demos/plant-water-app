import Foundation
import CoreBluetooth
import SwiftUI

@MainActor
@Observable
final class SoilBluetoothService: NSObject {
    var statusText: String = "Idle"
    var isBluetoothReady = false
    var isScanning = false
    var isConnected = false
    var soilRawValue = 0
    var sensorReadings: [SensorReadingModel] = []
    var livePoints: [LiveSensorPointModel] = []

    private let sensorReadingsService: SensorReadingsServiceProtocol

    private var centralManager: CBCentralManager?
    private var soilPeripheral: CBPeripheral?
    private var soilCharacteristic: CBCharacteristic?

    private let targetName = "SoilSensor"
    private let serviceUUID = CBUUID(string: "180C")
    private let characteristicUUID = CBUUID(string: "1234")

    init(sensorReadingsService: SensorReadingsServiceProtocol = SensorReadingsService()) {
        self.sensorReadingsService = sensorReadingsService
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func startScanning() {
        guard let centralManager else { return }

        guard centralManager.state == .poweredOn else {
            statusText = "Bluetooth not ready"
            return
        }

        guard !isScanning else { return }

        statusText = "Scanning..."
        isScanning = true

        centralManager.scanForPeripherals(withServices: nil)
    }

    func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
    }

    func disconnect() {
        guard let soilPeripheral else { return }
        centralManager?.cancelPeripheralConnection(soilPeripheral)
    }

    func loadSavedReadings() async {
        do {
            sensorReadings = try await sensorReadingsService.fetchReadings()
        } catch {
            print("Failed to load readings: \(error)")
        }
    }

    func saveCurrentReading() async -> Bool {
        guard isConnected else { return false }

        do {
            let savedReading = try await sensorReadingsService.saveReading(
                value: soilRawValue,
                emoji: emoji(for: soilRawValue),
                date: Date()
            )

            sensorReadings.insert(savedReading, at: 0)
            return true
        } catch {
            print("Failed to save reading: \(error)")
            return false
        }
    }

    func saveManualReading(type: ManualReadingType) async -> Bool {
        do {
            let savedReading = try await sensorReadingsService.saveReading(
                value: type.rawValue,
                emoji: type.emoji,
                date: Date()
            )

            sensorReadings.insert(savedReading, at: 0)
            return true
        } catch {
            print("Failed to save manual reading: \(error)")
            return false
        }
    }

    func deleteReadings(at offsets: IndexSet) {
        let readingsToDelete = offsets.map { sensorReadings[$0] }

        for reading in readingsToDelete {
            deleteReading(reading)
        }
    }

    // AI originally used explicit MainActor.run blocks.
    // After making the entire service @MainActor, simplified the code and
    // ensured async Tasks explicitly execute on the main actor for UI safety.
    func deleteReading(_ reading: SensorReadingModel) {
        Task { @MainActor in
            do {
                try await sensorReadingsService.deleteReading(id: reading.id)
                sensorReadings.removeAll { $0.id == reading.id }
            } catch {
                print("Failed to delete reading: \(error)")
            }
        }
    }

    func clearAllReadings() {
        Task { @MainActor in
            do {
                try await sensorReadingsService.clearAllReadings()
                sensorReadings.removeAll()
            } catch {
                print("Failed to clear all readings: \(error)")
            }
        }
    }

    var moistureDescription: String {
        moistureDescription(for: soilRawValue)
    }

    func moistureDescription(for value: Int) -> String {
        switch value {
        case -1:
            return "No Sensor Signal"
        case ..<1300:
            return "Wet Soil"
        case 1300..<2200:
            return "Moist Soil"
        case 2200..<3200:
            return "Dry Soil"
        default:
            return "Error"
        }
    }

    func emoji(for value: Int) -> String {
        switch value {
        case -1:
            return "📡"
        case ..<1300:
            return "💧"
        case 1300..<2200:
            return "🌱"
        case 2200..<3200:
            return "🔥"
        default:
            return "❓"
        }
    }
}

extension SoilBluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothReady = true
            statusText = "Bluetooth ready"
        default:
            isBluetoothReady = false
            statusText = "Bluetooth not available"
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name ?? ""
        let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? ""

        let match = name == targetName || advertisedName == targetName
        guard match else { return }

        statusText = "Connecting..."
        stopScanning()

        soilPeripheral = peripheral
        soilPeripheral?.delegate = self

        central.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        statusText = "Connected"
        livePoints.removeAll()
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        isConnected = false
        statusText = "Disconnected"
        livePoints.removeAll()
    }
}

extension SoilBluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services where service.uuid == serviceUUID {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics where characteristic.uuid == characteristicUUID {
            soilCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
            statusText = "Subscribed"
        }
    }

    // AI initially used withUnsafeBytes/load(as:), which assumed a valid two-byte
    // aligned payload. Updated to validate payload length and parse bytes explicitly
    // so malformed BLE packets fail gracefully instead of risking a crash.
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            statusText = "Sensor read error"
            print("Failed to update characteristic value: \(error)")
            return
        }

        guard let data = characteristic.value else { return }
        guard data.count >= 2 else {
            statusText = "Invalid sensor data"
            return
        }

        let lowByte = UInt16(data[data.startIndex])
        let highByte = UInt16(data[data.startIndex + 1])
        let rawValue = lowByte | (highByte << 8)
        let value = Int(rawValue)

        soilRawValue = value
        statusText = "Receiving data"

        livePoints.append(LiveSensorPointModel(date: Date(), value: value))

        if livePoints.count > 30 {
            livePoints.removeFirst()
        }
    }
}

enum ManualReadingType: Int, CaseIterable, Identifiable {
    case wet = 1200
    case moist = 1800
    case dry = 2600
    case noReading = -1

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .wet:
            return "Wet"
        case .moist:
            return "Moist"
        case .dry:
            return "Dry"
        case .noReading:
            return "No Signal"
        }
    }

    var emoji: String {
        switch self {
        case .wet:
            return "💧"
        case .moist:
            return "🌱"
        case .dry:
            return "🔥"
        case .noReading:
            return "📡"
        }
    }
}
