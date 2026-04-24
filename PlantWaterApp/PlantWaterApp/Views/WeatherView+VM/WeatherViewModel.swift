import Foundation
import Observation

/// View model responsible for fetching weather data and transforming it
/// into UI-friendly state for display, including a temperature timeline.
@MainActor
@Observable
final class WeatherViewModel {
    var past: [DailyForecastModel] = []
    var future: [DailyForecastModel] = []
    var currentTempF: Double?
    var temperatureTimeline: [TemperatureTimelineModel] = []
    var isLoading = false
    var errorMessage: String?

    private let weatherKitService: WeatherKitServiceProtocol

    init(weatherKitService: WeatherKitServiceProtocol = WeatherKitService()) {
        self.weatherKitService = weatherKitService
    }

    /// Loads weather data for a fixed location and updates observable state,
    /// including historical weather, current temperature, forecast, and timeline data.
    func loadForecast() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let result = try await weatherKitService.fetchWeather(
                latitude: 39.888,
                longitude: -75.343
            )

            past = result.past
            future = result.future
            currentTempF = result.currentTempF
            buildTemperatureTimeline(using: result)

        } catch {
            clearWeatherData()
            errorMessage = "Unable to load weather."
        }
    }

    /// Builds a unified temperature timeline for charting by combining
    /// historical, current, and forecast values into a single ordered sequence.
    private func buildTemperatureTimeline(using result: WeatherResultModel) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var timeline: [TemperatureTimelineModel] = []
        let futureExcludingToday = filterOutToday(from: result.future, using: calendar, today: today)

        timeline += makePastTimelineEntries(from: result.past)
        timeline.append(makeTodayTimelineEntry(from: result, today: today))
        timeline += makeFutureTimelineEntries(from: futureExcludingToday)

        temperatureTimeline = timeline
    }

    /// Clears weather-related UI state after a failed fetch.
    private func clearWeatherData() {
        past = []
        future = []
        currentTempF = nil
        temperatureTimeline = []
    }

    private func makePastTimelineEntries(from past: [DailyForecastModel]) -> [TemperatureTimelineModel] {
        past.map { day in
            TemperatureTimelineModel(
                date: day.date,
                highF: day.highF,
                lowF: day.lowF,
                currentF: nil,
                kind: .past
            )
        }
    }

    private func makeTodayTimelineEntry(
        from result: WeatherResultModel,
        today: Date
    ) -> TemperatureTimelineModel {
        let todayForecast = result.future.first

        return TemperatureTimelineModel(
            date: today,
            highF: todayForecast?.highF ?? result.currentTempF,
            lowF: todayForecast?.lowF ?? result.currentTempF,
            currentF: result.currentTempF,
            kind: .today
        )
    }

    private func makeFutureTimelineEntries(from future: [DailyForecastModel]) -> [TemperatureTimelineModel] {
        future.map { day in
            TemperatureTimelineModel(
                date: day.date,
                highF: day.highF,
                lowF: day.lowF,
                currentF: nil,
                kind: .future
            )
        }
    }

    private func filterOutToday(
        from future: [DailyForecastModel],
        using calendar: Calendar,
        today: Date
    ) -> [DailyForecastModel] {
        future.filter { !calendar.isDate($0.date, inSameDayAs: today) }
    }
}

// FilterOutToday Method:
// AI originally appended all future entries after creating a dedicated .today entry,
// which could duplicate today's forecast in the chart. Filtered today out of the
// future timeline entries so each day appears only once.
