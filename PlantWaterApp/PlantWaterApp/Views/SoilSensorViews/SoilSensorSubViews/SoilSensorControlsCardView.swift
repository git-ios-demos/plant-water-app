import SwiftUI

struct SoilSensorControlsCardView: View {
    let bluetooth: SoilBluetoothService
    @Binding var isSaveAlertPresented: Bool
    @Binding var isManualSheetPresented: Bool
    let isWaitingForStableReading: Bool

    @State private var isSaveFailedAlertPresented = false

    var body: some View {
        VStack {
            Button {
                bluetooth.startScanning()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                    Text("Scan")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.green.opacity(0.9), .green],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if bluetooth.isConnected {
                Button {
                    Task {
                        let isSaved = await bluetooth.saveCurrentReading()
                        if isSaved {
                            isSaveAlertPresented = true
                        } else {
                            isSaveFailedAlertPresented = true
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Reading")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue.opacity(0.9), .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isWaitingForStableReading)
                .opacity(isWaitingForStableReading ? 0.6 : 1)

            } else {
                Button {
                    isManualSheetPresented = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle")
                        Text("Add Demo Reading")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue.opacity(0.9), .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            Button {
                bluetooth.disconnect()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "xmark.circle")
                    Text("Disconnect")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.red.opacity(0.4), lineWidth: 1)
                )
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!bluetooth.isConnected)
            .opacity(!bluetooth.isConnected ? 0.5 : 1)
        }
        .alert("Save Failed", isPresented: $isSaveFailedAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Unable to save reading. Please try again.")
        }
    }
}

#Preview {
    SoilSensorControlsCardView(
        bluetooth: SoilBluetoothService(),
        isSaveAlertPresented: .constant(false),
        isManualSheetPresented: .constant(false),
        isWaitingForStableReading: true
    )
}

// This card adapts available actions based on connection state.
// When connected, users can save live sensor readings. When not connected,
// a manual entry path is provided to support demo scenarios without hardware.
