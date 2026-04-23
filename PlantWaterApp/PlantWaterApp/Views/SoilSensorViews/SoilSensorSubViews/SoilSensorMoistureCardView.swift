import SwiftUI

struct SoilSensorMoistureCardView: View {
    let bluetooth: SoilBluetoothService
    let isWaitingForStableReading: Bool
    let moistureEmoji: String
    let moistureColor: Color

    var body: some View {
        VStack(spacing: 20) {
            Text("Raw Value")
                .font(.headline)
                .foregroundStyle(.secondary)

            if bluetooth.isConnected {
                if isWaitingForStableReading {
                    ProgressView()
                        .controlSize(.large)

                    Text("Stabilizing Sensor...")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(bluetooth.soilRawValue)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()

                    Text(moistureEmoji)
                        .font(.system(size: 40))

                    Text(bluetooth.moistureDescription)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(moistureColor)
                }
            } else {
                Text("—")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)

                Text("📡")
                    .font(.system(size: 40))

                Text("No Sensor Signal")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    SoilSensorMoistureCardView(
        bluetooth: SoilBluetoothService(),
        isWaitingForStableReading: true,
        moistureEmoji: "🔥",
        moistureColor: .red
    )
}
