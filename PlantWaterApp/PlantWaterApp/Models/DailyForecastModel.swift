import Foundation

/// Represents a single day's weather forecast returned from the service layer,
/// including high/low temperatures and a condition description.
struct DailyForecastModel: Identifiable {
    let id = UUID()
    let date: Date
    let highF: Double
    let lowF: Double
    let condition: String
}

extension DailyForecastModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "DailyForecastModel(id: \(id), date: \(date), highF: \(highF), lowF: \(lowF), condition: \(condition))"
    }
}
