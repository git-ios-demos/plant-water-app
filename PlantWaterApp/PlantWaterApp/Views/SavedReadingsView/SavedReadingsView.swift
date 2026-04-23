import SwiftUI

struct SavedReadingsView: View {
    @Environment(SoilSenseTabViewModel.self) private var soilSenseTabVM

    @State private var isClearAllAlertPresented = false

    private let rowDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private var bluetooth: SoilBluetoothService {
        soilSenseTabVM.soilBluetoothService
    }

    var body: some View {
        NavigationStack {
            Group {
                if bluetooth.sensorReadings.isEmpty {
                    ContentUnavailableView(
                        "No Saved Readings",
                        systemImage: "tray",
                        description: Text("Save a reading from the Sensor tab to see it here.")
                    )
                } else {
                    List {
                        ForEach(bluetooth.sensorReadings) { reading in
                            readingRow(reading)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        bluetooth.deleteReading(reading)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .onDelete(perform: bluetooth.deleteReadings)
                    }
                }
            }
            .navigationTitle("Saved Readings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !bluetooth.sensorReadings.isEmpty {
                        Button("Clear All", role: .destructive) {
                            isClearAllAlertPresented = true
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if !bluetooth.sensorReadings.isEmpty {
                        EditButton()
                    }
                }
            }
            .alert("Clear all saved readings?", isPresented: $isClearAllAlertPresented) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    bluetooth.clearAllReadings()
                }
            } message: {
                Text("This will permanently remove all saved soil readings.")
            }
        }
    }

    @ViewBuilder
    private func readingRow(_ reading: SensorReadingModel) -> some View {
        HStack(spacing: 12) {
            Text(reading.emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(bluetooth.moistureDescription(for: reading.value))
                    .font(.headline)

                Text("Raw Value: \(reading.value)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(rowDateFormatter.string(from: reading.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
//    SavedReadingsView()
}
