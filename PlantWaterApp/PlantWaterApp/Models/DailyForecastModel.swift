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

// I prefer using an immutable struct to model forecast data as a value type.
// This aligns with a value driven architecture and avoids shared mutable state,
// which simplifies reasoning in a concurrent environment.
//
// AI generated versions initially introduced unnecessary mutability,
// which was removed to favor Swift's synthesized memberwise initializer
// and keep the model lightweight and predictable.
