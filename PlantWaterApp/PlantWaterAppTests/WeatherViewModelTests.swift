import Testing
import Foundation
@testable import PlantWaterApp

struct WeatherViewModelTests {
    @Test
    @MainActor
    func loadForecast_success_updatesPublishedState() async {
        // Arrange
        let mockResult = WeatherResultModel(
            past: [
                makeForecast(
                    daysFromNow: -1,
                    high: 68,
                    low: 50,
                    condition: "Cloudy"
                )
            ],
            currentTempF: 75,
            future: [
                makeForecast(
                    daysFromNow: 1,
                    high: 80,
                    low: 60,
                    condition: "Sunny"
                )
            ]
        )

        let mockService = MockWeatherKitService(result: .success(mockResult))
        let viewModel = WeatherViewModel(weatherKitService: mockService)

        // Act
        await viewModel.loadForecast()

        // Assert
        #expect(viewModel.past.count == 1)
        #expect(viewModel.future.count == 1)
        #expect(viewModel.currentTempF == 75)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)

        #expect(!viewModel.temperatureTimeline.isEmpty)
        #expect(viewModel.temperatureTimeline.contains(where: { $0.kind == .today }))
    }

    @Test
    @MainActor
    func loadForecast_failure_clearsData_andSetsError() async {
        // Arrange
        let mockService = MockWeatherKitService(
            result: .failure(WeatherKitServiceError.failedToFetchWeather)
        )
        let viewModel = WeatherViewModel(weatherKitService: mockService)

        // Act
        await viewModel.loadForecast()

        // Assert
        #expect(viewModel.past.isEmpty)
        #expect(viewModel.future.isEmpty)
        #expect(viewModel.currentTempF == nil)
        #expect(viewModel.temperatureTimeline.isEmpty)
        #expect(viewModel.isLoading == false)

        // Prefer the exact string only if your VM intentionally maps to this UI copy.
        #expect(viewModel.errorMessage == "Unable to load weather.")
    }

    @Test
    @MainActor
    func loadForecast_withEmptyPastAndFuture_createsTodayOnlyTimeline() async {
        // Arrange
        let mockResult = WeatherResultModel(
            past: [],
            currentTempF: 70,
            future: []
        )

        let mockService = MockWeatherKitService(result: .success(mockResult))
        let viewModel = WeatherViewModel(weatherKitService: mockService)

        // Act
        await viewModel.loadForecast()

        // Assert
        #expect(viewModel.temperatureTimeline.count == 1)
        #expect(viewModel.temperatureTimeline.first?.kind == .today)
        #expect(viewModel.currentTempF == 70)
    }

    @Test
    @MainActor
    func loadForecast_withPastTodayAndFuture_buildsTimelineKindsCorrectly() async {
        // Arrange
        let mockPast = (1...7).map { day in
            makeForecast(
                daysFromNow: -day,
                high: 60 + Double(day),
                low: 40 + Double(day),
                condition: "Cloudy"
            )
        }
        .sorted { $0.date < $1.date }

        let mockFuture = (1...7).map { day in
            makeForecast(
                daysFromNow: day,
                high: 80 + Double(day),
                low: 60 + Double(day),
                condition: "Sunny"
            )
        }

        let mockResult = WeatherResultModel(
            past: mockPast,
            currentTempF: 75,
            future: mockFuture
        )

        let mockService = MockWeatherKitService(result: .success(mockResult))
        let viewModel = WeatherViewModel(weatherKitService: mockService)

        // Act
        await viewModel.loadForecast()

        // Assert
        let timeline = viewModel.temperatureTimeline

        #expect(timeline.contains(where: { $0.kind == .past }))
        #expect(timeline.contains(where: { $0.kind == .today }))
        #expect(timeline.contains(where: { $0.kind == .future }))

        let todayCount = timeline.filter { $0.kind == .today }.count
        #expect(todayCount == 1)
    }

    @Test
    @MainActor
    func loadForecast_withFullData_createsFifteenPointTimeline() async {
        // Arrange
        let mockPast = (1...7).map { day in
            makeForecast(
                daysFromNow: -day,
                high: 65 + Double(day),
                low: 45 + Double(day),
                condition: "Rain"
            )
        }
        .sorted { $0.date < $1.date }

        let mockFuture = (1...7).map { day in
            makeForecast(
                daysFromNow: day,
                high: 70 + Double(day),
                low: 50 + Double(day),
                condition: "Sunny"
            )
        }

        let mockResult = WeatherResultModel(
            past: mockPast,
            currentTempF: 72,
            future: mockFuture
        )

        let mockService = MockWeatherKitService(result: .success(mockResult))
        let viewModel = WeatherViewModel(weatherKitService: mockService)

        // Act
        await viewModel.loadForecast()

        // Assert
        #expect(viewModel.temperatureTimeline.count == 15) // 7 past + 1 today + 7 future
    }
}

// MARK: - Helpers

private extension WeatherViewModelTests {
    func makeForecast(
        daysFromNow: Int,
        high: Double,
        low: Double,
        condition: String,
        calendar: Calendar = .current
    ) -> DailyForecastModel {
        let baseDate = calendar.startOfDay(for: Date())
        let date = calendar.date(byAdding: .day, value: daysFromNow, to: baseDate) ?? baseDate

        return DailyForecastModel(
            date: date,
            highF: high,
            lowF: low,
            condition: condition
        )
    }
}

private struct MockWeatherKitService: WeatherKitServiceProtocol {
    let result: Result<WeatherResultModel, Error>

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResultModel {
        try result.get()
    }
}
