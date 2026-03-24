import Foundation

struct TimeEntry: Identifiable, Codable {
    let id: UUID
    let start: Date
    let end: Date
    let note: String?

    init(id: UUID = UUID(), start: Date, end: Date, note: String? = nil) {
        self.id = id
        self.start = start
        self.end = end
        let cleaned = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.note = (cleaned?.isEmpty == true) ? nil : cleaned
    }

    var duration: TimeInterval {
        max(0, end.timeIntervalSince(start))
    }
}
