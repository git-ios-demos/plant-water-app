import SwiftUI

struct SoilSensorConnectionCardView: View {
    let bluetooth: SoilBluetoothService

    var body: some View {
        VStack {
            Text("Connection Status")
                .font(.headline)

            Text(bluetooth.statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Circle()
                    .fill(bluetooth.isConnected ? .green : .red)
                    .frame(width: 24, height: 24)

                Text(bluetooth.isConnected ? "Connected" : "Not Connected")
                    .font(.headline)
                    .foregroundStyle(bluetooth.isConnected ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    SoilSensorConnectionCardView(bluetooth: SoilBluetoothService())
}
