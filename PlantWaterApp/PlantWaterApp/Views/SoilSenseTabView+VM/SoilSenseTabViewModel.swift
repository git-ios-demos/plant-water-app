import SwiftUI

@Observable
final class SoilSenseTabViewModel {
    let soilBluetoothService: SoilBluetoothService

    init(soilBluetoothService: SoilBluetoothService = SoilBluetoothService()) {
        self.soilBluetoothService = soilBluetoothService
    }
}
