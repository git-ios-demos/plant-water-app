import Foundation
import CoreLocation
import WeatherKit

protocol WeatherKitServiceProtocol {
    /// Fetches historical, current, and forecast weather for a given location.
    ///
    /// - Parameters:
    ///   - latitude: The latitude of the location.
    ///   - longitude: The longitude of the location.
    /// - Returns: A `WeatherResultModel` containing the past 7 days, current temperature,
    ///   and next 7 days of daily weather.
    /// - Throws: `WeatherKitServiceError` if the request fails.
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResultModel
}

struct WeatherKitService: WeatherKitServiceProtocol {
    private let service = WeatherService.shared

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResultModel {
        do {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let calendar = Calendar.current

            // Normalize to start of day to avoid partial-day inconsistencies
            let today = calendar.startOfDay(for: Date())

            // Build 7-day historical and forecast ranges
            let (pastStartDate, futureEndDate) = try validateDateRanges(calendar: calendar, today: today)
            let pastStartDateToToday = WeatherQuery.daily(startDate: pastStartDate, endDate: today)
            let todayToEndFutureDate = WeatherQuery.daily(startDate: today, endDate: futureEndDate)

            // Fetch all weather data concurrently
            async let currentWeather = service.weather(for: location)
            async let pastDailyWeather = service.weather(for: location, including: pastStartDateToToday)
            async let futureDailyWeather = service.weather(for: location, including: todayToEndFutureDate)
            let (weather, pastForecast, futureForecast) = try await (
                currentWeather, pastDailyWeather, futureDailyWeather
            )

            let past = buildPastForecast(from: pastForecast)
            let future = buildFutureForecast(from: futureForecast)
            let currentTempF = buildCurrentTemperature(from: weather)

            return WeatherResultModel(
                past: past,
                currentTempF: currentTempF,
                future: future
            )
            // AI originally collapsed all failures into failedToFetchWeather,
            // which hid the specific date-range validation error.
            // Updated the catch handling to preserve WeatherKitServiceError cases.
        } catch let error as WeatherKitServiceError {
            throw error
        } catch {
            throw WeatherKitServiceError.failedToFetchWeather
        }
    }

    private func buildPastForecast(from forecast: Forecast<DayWeather>) -> [DailyForecastModel] {
        forecast
            .prefix(7)
            .map { day in
                DailyForecastModel(
                    date: day.date,
                    highF: day.highTemperature.converted(to: .fahrenheit).value,
                    lowF: day.lowTemperature.converted(to: .fahrenheit).value,
                    condition: day.condition.description
                )
            }
    }

    private func buildFutureForecast(from forecast: Forecast<DayWeather>) -> [DailyForecastModel] {
        forecast
            .prefix(7)
            .map { day in
                DailyForecastModel(
                    date: day.date,
                    highF: day.highTemperature.converted(to: .fahrenheit).value,
                    lowF: day.lowTemperature.converted(to: .fahrenheit).value,
                    condition: day.condition.description
                )
            }
    }

    private func buildCurrentTemperature(from weather: Weather) -> Double {
        weather.currentWeather.temperature
            .converted(to: .fahrenheit)
            .value
    }

    private func validateDateRanges(
        calendar: Calendar,
        today: Date
    ) throws -> (pastStartDate: Date, futureEndDate: Date) {
        guard
            let pastStartDate = calendar.date(byAdding: .day, value: -7, to: today),
            let futureEndDate = calendar.date(byAdding: .day, value: 7, to: today)
        else {
            throw WeatherKitServiceError.failedToFetchDateRange
        }
        return (pastStartDate, futureEndDate)
    }
}

enum WeatherKitServiceError: LocalizedError {
    case failedToFetchDateRange
    case failedToFetchWeather

    var errorDescription: String? {
        switch self {
        case .failedToFetchDateRange:
            return "Unable to fetch date range."
        case .failedToFetchWeather:
            return "Unable to load weather data."
        }
    }
}
