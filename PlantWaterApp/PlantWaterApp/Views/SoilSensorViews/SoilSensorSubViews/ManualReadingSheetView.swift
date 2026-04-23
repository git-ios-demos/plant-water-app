import SwiftUI

struct ManualReadingSheetView: View {
    let bluetooth: SoilBluetoothService
    @Binding var isPresented: Bool
    @Binding var isSaveAlertPresented: Bool

    @State private var isSaveFailedAlertPresented = false

    var body: some View {
        NavigationStack {
            List(ManualReadingType.allCases) { type in
                Button {
                    Task {
                        let success = await bluetooth.saveManualReading(type: type)

                        if success {
                            isPresented = false
                            isSaveAlertPresented = true
                        } else {
                            isSaveFailedAlertPresented = true
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text(type.emoji)
                            .font(.title3)

                        Text(type.title)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
            .navigationTitle("Record Reading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .alert("Save Failed", isPresented: $isSaveFailedAlertPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Could not save your reading. Please try again.")
        }
    }
}

#Preview {
    ManualReadingSheetView(
        bluetooth: SoilBluetoothService(),
        isPresented: .constant(true),
        isSaveAlertPresented: .constant(false)
    )
}

#Preview {
    ManualReadingSheetView(
        bluetooth: SoilBluetoothService(),
        isPresented: .constant(true),
        isSaveAlertPresented: .constant(false)
    )
}
