import SwiftUI

/// Ein Kalendertag im PDF: ein Block mit Kopf (Summe, Themen) und allen Zeiten darunter.
struct ReportDaySection: Identifiable {
    let id: UUID
    let dayStart: Date
    let titleLine: String
    let totalDuration: TimeInterval
    let themesLine: String
    let entries: [TimeEntry]
}

struct TimeReportView: View {
    let daySections: [ReportDaySection]
    let createdAt: Date
    /// 0-basiert
    let pageIndex: Int
    let totalPages: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerBlock

            Divider()

            if daySections.isEmpty {
                Text("Keine Eintraege vorhanden.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(daySections) { section in
                        dayBlock(section)
                    }
                }

                Spacer(minLength: 0)
            }

            if totalPages > 1 {
                Text("Seite \(pageIndex + 1) von \(totalPages)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(24)
        .frame(width: 842, height: 595, alignment: .topLeading)
        .background(Color.white)
    }

    @ViewBuilder
    private var headerBlock: some View {
        if pageIndex == 0 {
            Text("Zeiterfassung - Projektarbeit")
                .font(.title2.bold())

            Text("Erstellt am \(createdAt.formattedGerman(date: .abbreviated, time: .shortened))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } else {
            Text("Zeiterfassung - Projektarbeit")
                .font(.title3.bold())
            Text("Fortsetzung — Seite \(pageIndex + 1) von \(totalPages)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func dayBlock(_ section: ReportDaySection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(section.titleLine)
                    .font(.title3.bold())
                Spacer()
                Text(section.totalDuration.formattedDuration)
                    .font(.title3.bold())
                    .monospacedDigit()
            }

            Group {
                if section.themesLine.isEmpty {
                    Text("Themen: —")
                        .font(.body)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Themen: \(section.themesLine)")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .lineLimit(8)
            .truncationMode(.tail)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                ForEach(section.entries) { entry in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(entry.start.formattedGerman(date: .omitted, time: .shortened)) – \(entry.end.formattedGerman(date: .omitted, time: .shortened))")
                        Text("(\(entry.duration.formattedDuration))")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                }
            }
            .padding(.leading, 4)
        }
    }
}
