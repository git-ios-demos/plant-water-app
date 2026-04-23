import SwiftUI
import Charts

struct WeatherView: View {
    @Environment(SoilSenseTabViewModel.self) private var soilSenseTabVM

    @State private var weatherVM = WeatherViewModel()
    @State private var chartScrollPosition: Date = Date()

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()

    private var initialChartScrollPosition: Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .hour, value: -24, to: today) ?? today
    }

    private var currentChartDate: Date {
        Date()
    }

    private var bluetooth: SoilBluetoothService {
        soilSenseTabVM.soilBluetoothService
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                if weatherVM.isLoading {
                    ProgressView("Loading forecast...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                } else if let errorMessage = weatherVM.errorMessage {
                    ContentUnavailableView(
                        "Couldn’t Load Weather",
                        systemImage: "icloud.slash",
                        description: Text(errorMessage)
                    )
                } else {
                    timelineChartSection
                    listSection
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .task {
            await weatherVM.loadForecast()
            chartScrollPosition = initialChartScrollPosition
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let current = weatherVM.currentTempF {
                Text("Current: \(Int(current))°")
                    .font(.title)
                    .bold()
            }

            if let today = weatherVM.future.first {
                HStack(spacing: 8) {
                    Image(systemName: weatherSymbolName(for: today.condition))
                        .font(.title)
                        .foregroundStyle(.secondary)

                    Text("Today: \(Int(today.highF))° / \(Int(today.lowF))°")
                        .font(.title3)
                }
            } else {
                Text("Loading...")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var timelineChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Temperature Timeline")
                .font(.headline)

            Chart {
                ForEach(weatherVM.temperatureTimeline) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("High", entry.highF)
                    )

                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("High", entry.highF)
                    )
                    .symbolSize(50)

                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Low", entry.lowF)
                    )

                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Low", entry.lowF)
                    )
                    .symbolSize(50)

                    if entry.kind == .today,
                       let current = entry.currentF {
                        PointMark(
                            x: .value("Date", currentChartDate),
                            y: .value("Current", current)
                        )
                        .opacity(0)

                        ForEach(bluetooth.sensorReadings) { reading in
                            PointMark(
                                x: .value("Date", reading.date),
                                y: .value("Current", current)
                            )
                            .opacity(0)
                            .annotation(position: .top) {
                                VStack(spacing: 0) {
                                    Text("\(Int(current))°")
                                    Text(reading.emoji)
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .frame(height: 260)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 60 * 60 * 24 * 7)
            .chartScrollPosition(x: $chartScrollPosition)
            .chartYScale(domain: 32...100)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(dayFormatter.string(from: date))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 5)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
    }

    private var listSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Forecast")
                .font(.headline)

            ForEach(weatherVM.future) { day in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dayFormatter.string(from: day.date))
                            .font(.subheadline)
                            .bold()

                        Text(shortDateFormatter.string(from: day.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 50, alignment: .leading)

                    Image(systemName: weatherSymbolName(for: day.condition))
                        .font(.title3)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.condition.capitalized)
                            .font(.subheadline)

                        Text("High \(Int(day.highF))° • Low \(Int(day.lowF))°")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.vertical, 6)

                Divider()
            }
        }
    }

    private func weatherSymbolName(for condition: String) -> String {
        let lowercased = condition.lowercased()

        if lowercased.contains("thunder") || lowercased.contains("storm") {
            return "cloud.bolt.rain.fill"
        } else if lowercased.contains("drizzle") {
            return "cloud.drizzle.fill"
        } else if lowercased.contains("rain") || lowercased.contains("showers") {
            return "cloud.rain.fill"
        } else if lowercased.contains("snow") || lowercased.contains("sleet") || lowercased.contains("flurries") {
            return "cloud.snow.fill"
        } else if lowercased.contains("fog") || lowercased.contains("mist") || lowercased.contains("haze") {
            return "cloud.fog.fill"
        } else if lowercased.contains("wind") {
            return "wind"
        } else if lowercased.contains("partly")
                    || lowercased.contains("mostly clear")
                    || lowercased.contains("mostly sunny") {
            return "cloud.sun.fill"
        } else if lowercased.contains("cloud") || lowercased.contains("overcast") {
            return "cloud.fill"
        } else if lowercased.contains("clear") || lowercased.contains("sunny") {
            return "sun.max.fill"
        } else {
            return "cloud.sun.fill"
        }
    }
}
