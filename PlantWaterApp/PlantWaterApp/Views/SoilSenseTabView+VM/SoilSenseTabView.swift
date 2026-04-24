import SwiftUI

struct SoilSenseTabView: View {
    @State private var soilSenseTabVM = SoilSenseTabViewModel()

    private var bluetooth: SoilBluetoothService {
        soilSenseTabVM.soilBluetoothService
    }

    var body: some View {
        TabView {
            Tab {
                SoilSensorView()
            } label: {
                Label("Sensor", systemImage: "dot.radiowaves.left.and.right")
            }

            Tab {
                WeatherView()
            } label: {
                Label("Weather", systemImage: "cloud.sun")
            }

            Tab {
                SavedReadingsView()
            } label: {
                Label("Readings", systemImage: "list.bullet.rectangle")
            }
        }
        .task {
            await bluetooth.loadSavedReadings()
        }
        .environment(soilSenseTabVM)
    }
}

#Preview {
    SoilSenseTabView()
}

// The root tab view owns the tab level view model so the Bluetooth service
// is created once and shared across child views through environment injection.
// This avoids recreating CoreBluetooth state per tab while keeping service
// access behind view models.
