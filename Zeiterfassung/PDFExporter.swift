import Foundation
import SwiftUI

enum PDFExporter {
    private static let pageWidth: CGFloat = 842
    private static let pageHeight: CGFloat = 595
    /// Grobe Kapazitaet pro Seite: ganze Kalendertage werden nie geteilt, nur auf neue Seiten verteilt.
    private static let unitsPerPageBudget = 28

    @MainActor
    static func export(entries: [TimeEntry]) throws -> URL {
        let createdAt = Date()
        let sections = buildDaySections(from: entries)
        let pages = paginate(sections)
        let totalPages = max(pages.count, 1)

        let outputURL = documentsDirectory().appendingPathComponent("Zeiterfassung_Report.pdf")

        var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        guard let consumer = CGDataConsumer(url: outputURL as CFURL),
              let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw NSError(domain: "PDFExporter", code: 1, userInfo: [NSLocalizedDescriptionKey: "PDF-Kontext konnte nicht erstellt werden."])
        }

        for (index, slice) in pages.enumerated() {
            let reportView = TimeReportView(
                daySections: slice,
                createdAt: createdAt,
                pageIndex: index,
                totalPages: totalPages
            )
            let renderer = ImageRenderer(content: reportView)
            renderer.proposedSize = ProposedViewSize(width: pageWidth, height: pageHeight)
            renderer.scale = 1

            context.beginPDFPage(nil)
            renderer.render { _, renderInContext in
                renderInContext(context)
            }
            context.endPDFPage()
        }

        context.closePDF()

        return outputURL
    }

    /// Pro Kalendertag genau ein Block mit allen Eintraegen des Tages.
    private static func buildDaySections(from entries: [TimeEntry]) -> [ReportDaySection] {
        guard !entries.isEmpty else { return [] }

        let sorted = entries.sorted { $0.start < $1.start }
        let grouped = Dictionary(grouping: sorted) { Calendar.current.startOfDay(for: $0.start) }
        let daysDescending = grouped.keys.sorted(by: >)

        var sections: [ReportDaySection] = []

        for dayStart in daysDescending {
            guard let dayEntries = grouped[dayStart]?.sorted(by: { $0.start < $1.start }) else { continue }

            let total = dayEntries.reduce(0.0) { $0 + $1.duration }
            let rawNotes = dayEntries.compactMap(\.note).filter { !$0.isEmpty }
            var seen = Set<String>()
            let uniqueNotes = rawNotes.filter { seen.insert($0).inserted }
            let themes = uniqueNotes.joined(separator: "; ")

            let titleFull = dayEntries.first!.start.formattedGerman(date: .complete, time: .omitted)

            sections.append(
                ReportDaySection(
                    id: UUID(),
                    dayStart: dayStart,
                    titleLine: titleFull,
                    totalDuration: total,
                    themesLine: themes,
                    entries: dayEntries
                )
            )
        }

        return sections
    }

    /// Verteilt nur ganze Tage auf Seiten; ein Tag wird nie in mehrere Bloecke zerlegt.
    private static func paginate(_ sections: [ReportDaySection]) -> [[ReportDaySection]] {
        guard !sections.isEmpty else {
            return [[]]
        }

        var pages: [[ReportDaySection]] = []
        var current: [ReportDaySection] = []
        var units = 0

        for section in sections {
            let cost = 6 + section.entries.count

            if !current.isEmpty && units + cost > unitsPerPageBudget {
                pages.append(current)
                current = []
                units = 0
            }

            current.append(section)
            units += cost
        }

        if !current.isEmpty {
            pages.append(current)
        }

        return pages
    }

    private static func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
