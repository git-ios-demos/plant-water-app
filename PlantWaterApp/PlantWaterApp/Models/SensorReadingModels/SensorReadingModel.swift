import Foundation

/// Represents a single sensor reading captured at a point in time,
/// including the raw value and an associated emoji for visualization.
struct SensorReadingModel: Identifiable, Codable {
    let id: String
    let date: Date
    let value: Int
    let emoji: String
}

extension SensorReadingModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "SensorReadingModel(id: \(id), date: \(date), value: \(value), emoji: \(emoji))"
    }
}
