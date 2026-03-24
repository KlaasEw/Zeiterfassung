import SwiftUI

struct ManualEntrySheet: View {
    @EnvironmentObject private var store: TimeStore
    @Environment(\.dismiss) private var dismiss

    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var noteText = ""
    @State private var showValidationError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Zeitraum") {
                    DatePicker("Anfang", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Ende", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                }
                Section("Notiz") {
                    TextField("Optional", text: $noteText, axis: .vertical)
                        .lineLimit(2...8)
                }
            }
            .navigationTitle("Manueller Eintrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        save()
                    }
                }
            }
            .alert("Ungueltiger Zeitraum", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Die Endzeit muss nach der Anfangszeit liegen.")
            }
        }
    }

    private func save() {
        guard endDate > startDate else {
            showValidationError = true
            return
        }
        store.addManualEntry(start: startDate, end: endDate, note: noteText)
        dismiss()
    }
}
