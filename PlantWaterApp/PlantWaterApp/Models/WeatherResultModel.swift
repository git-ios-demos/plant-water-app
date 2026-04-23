import Foundation

/// Represents the weather data returned from the service layer,
/// including historical (past 7 days), current temperature, and future forecast (next 7 days).
struct WeatherResultModel {

    /// Daily weather data for the past 7 days (historical).
    let past: [DailyForecastModel]

    /// The current temperature in Fahrenheit.
    let currentTempF: Double

    /// Daily weather forecast for the next 7 days.
    let future: [DailyForecastModel]
}
