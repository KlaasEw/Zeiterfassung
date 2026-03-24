import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TimeStore

    @State private var noteText = ""
    @State private var editingEntry: TimeEntry?
    @State private var editedNoteText = ""
    @State private var pendingDeletionEntry: TimeEntry?
    @State private var showManualEntry = false

    private var statusTintBackground: some View {
        Group {
            if store.isClockedIn {
                LinearGradient(
                    colors: [Color.green.opacity(0.18), Color.green.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                LinearGradient(
                    colors: [Color.red.opacity(0.14), Color.red.opacity(0.06)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                statusTintBackground

                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 16) {
                                statusCard
                                clockButton
                                noteField
                            }
                            .padding()
                        }
                        .frame(height: geometry.size.height * 0.5, alignment: .top)

                        Divider()

                        recentEntriesSection
                            .frame(height: geometry.size.height * 0.5)
                    }
                }
            }
            .navigationTitle("Projektzeiterfassung")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showManualEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Eintrag manuell hinzufuegen")
                }
            }
            .sheet(isPresented: $showManualEntry) {
                ManualEntrySheet()
                    .environmentObject(store)
            }
            .sheet(item: $editingEntry) { entry in
                NavigationStack {
                    Form {
                        Section("Notiz") {
                            TextField("Notiz hinzufuegen oder bearbeiten", text: $editedNoteText, axis: .vertical)
                                .lineLimit(3...8)
                        }
                    }
                    .navigationTitle("Eintrag bearbeiten")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Abbrechen") {
                                editingEntry = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Speichern") {
                                saveEditedNote(for: entry)
                            }
                        }
                    }
                }
            }
        }
    }

    private var statusCard: some View {
        VStack(spacing: 8) {
            Text("Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(store.isClockedIn ? "eingestempelt" : "ausgestempelt")
                .font(.title3.bold())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var clockButton: some View {
        Button {
            if store.isClockedIn {
                store.clockOut(note: noteText)
                noteText = ""
            } else {
                store.clockIn()
            }
        } label: {
            Text(store.isClockedIn ? "AUSSTEMPELN" : "EINSTEMPELN")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 56)
        }
        .buttonStyle(.borderedProminent)
        .tint(store.isClockedIn ? .red : .green)
    }

    private var noteField: some View {
        TextField("Optionale Notiz", text: $noteText, axis: .vertical)
            .textFieldStyle(.roundedBorder)
            .lineLimit(5...12)
            .frame(minHeight: 120, alignment: .topLeading)
    }

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Letzte 3 Eintraege")
                    .font(.headline)
                Spacer()
                NavigationLink("Alle anzeigen") {
                    AllEntriesView(
                        onEdit: { entry in startEditing(entry) }
                    )
                }
                .font(.subheadline)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            List {
                ForEach(Array(store.entries.prefix(3))) { entry in
                    entryRow(entry)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private func entryRow(_ entry: TimeEntry) -> some View {
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
                startEditing(entry)
            } label: {
                Label("Notiz", systemImage: "square.and.pencil")
            }
            .tint(.blue)
        }
    }

    private func startEditing(_ entry: TimeEntry) {
        editedNoteText = entry.note ?? ""
        editingEntry = entry
    }

    private func saveEditedNote(for entry: TimeEntry) {
        store.updateNote(for: entry.id, note: editedNoteText)
        editingEntry = nil
    }
}
