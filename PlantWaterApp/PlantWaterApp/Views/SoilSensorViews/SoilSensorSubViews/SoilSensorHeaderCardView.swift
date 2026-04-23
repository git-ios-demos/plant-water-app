import SwiftUI

struct SoilSensorHeaderCardView: View {
    var body: some View {
        VStack {
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 75))
                .foregroundStyle(.green)

            Text("SoilSense")
                .font(.title)
                .fontWeight(.bold)

            Text("Live Bluetooth Moisture Reader")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SoilSensorHeaderCardView()
}
