import SwiftUI

struct AllEntriesView: View {
    @EnvironmentObject private var store: TimeStore
    let onEdit: (TimeEntry) -> Void

    @State private var pendingDeletionEntry: TimeEntry?
    @State private var pdfToShare: PDFShareItem?
    @State private var exportError: String?

    private struct PDFShareItem: Identifiable {
        let id = UUID()
        let url: URL
    }

    private var groupedEntries: [(date: Date, entries: [TimeEntry])] {
        let grouped = Dictionary(grouping: store.entries) { entry in
            Calendar.current.startOfDay(for: entry.start)
        }
        return grouped
            .map { (date: $0.key, entries: $0.value.sorted { $0.start > $1.start }) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            if store.entries.isEmpty {
                ContentUnavailableView(
                    "Keine Eintraege",
                    systemImage: "tray",
                    description: Text("Stemple zuerst ein und aus, um Zeiten zu erfassen.")
                )
            } else {
                ForEach(groupedEntries, id: \.date) { section in
                    Section(section.date.formattedGerman(date: .complete, time: .omitted)) {
                        ForEach(section.entries) { entry in
                            row(for: entry)
                        }
                    }
                }
            }
        }
        .navigationTitle("Alle Eintraege")
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("PDF exportieren") {
                    exportPDF()
                }
                .disabled(store.entries.isEmpty)
            }
        }
        .sheet(item: $pdfToShare) { item in
            ActivityShareSheet(items: [item.url])
        }
        .alert("PDF-Export fehlgeschlagen", isPresented: .constant(exportError != nil), actions: {
            Button("OK") { exportError = nil }
        }, message: {
            Text(exportError ?? "")
        })
    }

    private func exportPDF() {
        do {
            let url = try PDFExporter.export(entries: store.entries.reversed())
            exportError = nil
            pdfToShare = PDFShareItem(url: url)
        } catch {
            exportError = error.localizedDescription
        }
    }

    private func row(for entry: TimeEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.start.formattedGerman(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Spacer()
                Text(entry.duration.formattedDuration)
                    .font(.subheadline.monospacedDigit())
            }
            HStack(spacing: 8) {
                Text("Von \(entry.start.formattedGerman(date: .omitted, time: .shortened))")
                Text("Bis \(entry.end.formattedGerman(date: .omitted, time: .shortened))")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if let note = entry.note {
                Text(note)
                    .font(.footnote)
            }
        }
        .padding(.vertical, 4)
        .popover(
            isPresented: Binding(
                get: { pendingDeletionEntry?.id == entry.id },
                set: { newValue in
                    if !newValue, pendingDeletionEntry?.id == entry.id {
                        pendingDeletionEntry = nil
                    }
                }
            )
        ) {
            DeleteEntryConfirmationPopover(
                entry: entry,
                onCancel: { pendingDeletionEntry = nil },
                onConfirm: {
                    store.deleteEntry(id: entry.id)
                    pendingDeletionEntry = nil
                }
            )
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                pendingDeletionEntry = entry
            } label: {
                Label("Loeschen", systemImage: "trash")
            }

            Button {
                onEdit(entry)
            } label: {
                Label("Notiz", systemImage: "square.and.pencil")
            }
            .tint(.blue)
        }
    }
}
