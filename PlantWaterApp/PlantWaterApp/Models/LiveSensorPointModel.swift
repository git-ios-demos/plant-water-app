import Foundation

/// Represents a real-time sensor data point used for live updates,
/// such as streaming values in a chart or monitoring UI.
struct LiveSensorPointModel: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
}

extension LiveSensorPointModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "LiveSensorPointModel(id: \(id), date: \(date), value: \(value))"
    }
}
