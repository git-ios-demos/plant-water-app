import Foundation

/// Represents a historical temperature data point used for tracking or charting past values.
struct TemperatureHistoryModel: Identifiable {
    let id = UUID()
    let date: Date
    let temperatureF: Double
}

extension TemperatureHistoryModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "TemperatureHistoryModel(id: \(id), date: \(date), temperatureF: \(temperatureF))"
    }
}
