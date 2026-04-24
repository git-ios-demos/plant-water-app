import SwiftUI

@Observable
final class SoilSenseTabViewModel {
    let soilBluetoothService: SoilBluetoothService

    init(soilBluetoothService: SoilBluetoothService = SoilBluetoothService()) {
        self.soilBluetoothService = soilBluetoothService
    }
}

// A custom EnvironmentKey could also share `SoilBluetoothService` directly,
// but that would inject the service into views and weaken the MVVM boundary
// used throughout this project.
//
// This root view model owns the shared Bluetooth service so child view models
// across tabs can receive the same service instance while keeping views focused
// on rendering and user interaction.
