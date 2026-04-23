import SwiftUI
import Charts

struct SoilSensorLiveChartCardView: View {
    let bluetooth: SoilBluetoothService
    let isWaitingForStableReading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if bluetooth.isConnected && !isWaitingForStableReading && !bluetooth.livePoints.isEmpty {
                Chart(bluetooth.livePoints) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("ADC", point.value)
                    )

                    PointMark(
                        x: .value("Time", point.date),
                        y: .value("ADC", point.value)
                    )
                    .symbolSize(30)
                }
                .frame(height: 170)
                .chartYScale(domain: 1000...2600)
                .chartXVisibleDomain(length: 20)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .second, count: 5)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.second())
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [1250, 1750, 2350]) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let adc = value.as(Int.self) {
                                switch adc {
                                case 1250:
                                    Text("Wet")
                                case 1750:
                                    Text("Moist")
                                case 2350:
                                    Text("Dry")
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Live Chart Yet",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Connect to the sensor to start plotting live readings.")
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview("Not connected") {
    SoilSensorLiveChartCardView(
        bluetooth: SoilBluetoothService(),
        isWaitingForStableReading: true
    )
}
