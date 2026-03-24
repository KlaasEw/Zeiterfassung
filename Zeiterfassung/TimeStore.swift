import Foundation

@MainActor
final class TimeStore: ObservableObject {
    @Published private(set) var entries: [TimeEntry] = []
    @Published private(set) var activeStart: Date?

    private let fileName = "time_entries.json"
    private let activeFileName = "active_start.json"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        load()
    }

    var isClockedIn: Bool {
        activeStart != nil
    }

    func clockIn() {
        guard activeStart == nil else { return }
        activeStart = Date()
        saveActiveStart()
    }

    func clockOut(note: String) {
        guard let start = activeStart else { return }
        let entry = TimeEntry(start: start, end: Date(), note: note)
        entries.insert(entry, at: 0)
        activeStart = nil
        saveAll()
    }

    func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }

    func deleteEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        saveEntries()
    }

    func updateNote(for id: UUID, note: String) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        let current = entries[index]
        entries[index] = TimeEntry(id: current.id, start: current.start, end: current.end, note: note)
        saveEntries()
    }

    /// Manuell erfasster Eintrag; Dauer ergibt sich aus Ende minus Anfang.
    @discardableResult
    func addManualEntry(start: Date, end: Date, note: String) -> Bool {
        guard end > start else { return false }
        let entry = TimeEntry(start: start, end: end, note: note)
        entries.insert(entry, at: 0)
        saveEntries()
        return true
    }

    private func saveAll() {
        saveEntries()
        saveActiveStart()
    }

    private func saveEntries() {
        do {
            let data = try encoder.encode(entries)
            try data.write(to: entriesURL(), options: [.atomic])
        } catch {
            print("Fehler beim Speichern der Eintraege: \(error)")
        }
    }

    private func saveActiveStart() {
        do {
            let data = try encoder.encode(activeStart)
            try data.write(to: activeStartURL(), options: [.atomic])
        } catch {
            print("Fehler beim Speichern des aktiven Starts: \(error)")
        }
    }

    private func load() {
        do {
            let url = entriesURL()
            if FileManager.default.fileExists(atPath: url.path) {
                let data = try Data(contentsOf: url)
                entries = try decoder.decode([TimeEntry].self, from: data)
            }
        } catch {
            print("Fehler beim Laden der Eintraege: \(error)")
            entries = []
        }

        do {
            let url = activeStartURL()
            if FileManager.default.fileExists(atPath: url.path) {
                let data = try Data(contentsOf: url)
                activeStart = try decoder.decode(Date?.self, from: data)
            }
        } catch {
            print("Fehler beim Laden des aktiven Starts: \(error)")
            activeStart = nil
        }
    }

    private func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func entriesURL() -> URL {
        documentsDirectory().appendingPathComponent(fileName)
    }

    private func activeStartURL() -> URL {
        documentsDirectory().appendingPathComponent(activeFileName)
    }
}
