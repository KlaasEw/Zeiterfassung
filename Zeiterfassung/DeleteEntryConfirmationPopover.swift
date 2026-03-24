import SwiftUI

/// Loesch-Rueckfrage, an den ausloesenden Eintrag gekoppelt (Popover / kompaktes Sheet).
struct DeleteEntryConfirmationPopover: View {
    let entry: TimeEntry
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Eintrag wirklich loeschen?")
                .font(.headline)
            Text("Der Eintrag vom \(entry.start.formattedGerman(date: .abbreviated, time: .shortened)) wird dauerhaft entfernt.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button("Abbrechen", action: onCancel)
                Spacer()
                Button("Loeschen", role: .destructive, action: onConfirm)
            }
        }
        .padding()
        .frame(minWidth: 280)
    }
}
