import Foundation

extension Date {
    private static let germanLocale = Locale(identifier: "de_DE")

    /// Einheitlich deutsche Datums-/Zeitdarstellung (z. B. Wochentag „Dienstag“ statt „Tuesday“).
    func formattedGerman(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle) -> String {
        formatted(Date.FormatStyle(date: date, time: time, locale: Self.germanLocale))
    }
}
