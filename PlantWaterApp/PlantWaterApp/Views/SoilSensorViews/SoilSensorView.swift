import SwiftUI
import Charts

struct SoilSensorView: View {
    @Environment(SoilSenseTabViewModel.self) private var soilSenseTabVM

    @State private var isWaitingForStableReading = false
    @State private var isManualSheetPresented = false
    @State private var isSaveAlertPresented = false
    @State private var stabilizationTask: Task<Void, Never>?

    private var bluetooth: SoilBluetoothService {
        soilSenseTabVM.soilBluetoothService
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SoilSensorHeaderCardView()
                SoilSensorConnectionCardView(bluetooth: bluetooth)
                SoilSensorMoistureCardView(
                    bluetooth: bluetooth,
                    isWaitingForStableReading: isWaitingForStableReading,
                    moistureEmoji: moistureEmoji,
                    moistureColor: moistureColor
                )
                SoilSensorLiveChartCardView(bluetooth: bluetooth, isWaitingForStableReading: isWaitingForStableReading)
                SoilSensorControlsCardView(
                    bluetooth: bluetooth,
                    isSaveAlertPresented: $isSaveAlertPresented,
                    isManualSheetPresented: $isManualSheetPresented,
                    isWaitingForStableReading: isWaitingForStableReading
                )
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $isManualSheetPresented) {
            ManualReadingSheetView(
                bluetooth: bluetooth,
                isPresented: $isManualSheetPresented,
                isSaveAlertPresented: $isSaveAlertPresented
            )
        }
        .alert("Success!", isPresented: $isSaveAlertPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your reading has been saved.")
        }
        .onChange(of: bluetooth.isConnected) { _, isConnected in
            stabilizationTask?.cancel()

            if isConnected {
                isWaitingForStableReading = true

                stabilizationTask = Task {
                    try? await Task.sleep(for: .seconds(5))
                    guard !Task.isCancelled, bluetooth.isConnected else { return }
                    isWaitingForStableReading = false
                }
            } else {
                isWaitingForStableReading = false
            }
        }
        .onDisappear {
            stabilizationTask?.cancel()
        }
    }

    private var moistureColor: Color {
        switch bluetooth.soilRawValue {
        case -1:
            return .orange
        case ..<1300:
            return .blue
        case 1300..<2200:
            return .green
        case 2200..<3200:
            return .red
        default:
            return .primary
        }
    }

    private var moistureEmoji: String {
        switch bluetooth.soilRawValue {
        case -1:
            return "📡"
        case ..<1300:
            return "💧"
        case 1300..<2200:
            return "🌱"
        case 2200..<3200:
            return "🔥"
        default:
            return "❓"
        }
    }
}
