# Projektzeiterfassung
Kleine **SwiftUI**-App (iOS 16+) zur privaten Zeiterfassung – ohne Cloud, ohne Backend.
## Funktionen
- **Ein-/Ausstempeln** mit Statusanzeige und optionalem Notizfeld
- **Manuelle Einträge** (Plus oben rechts): Anfang, Ende, Notiz
- **Letzte drei Einträge** auf der Startseite; **alle Einträge** gruppiert nach Tagen
- Einträge **bearbeiten** (Notiz), **löschen** (mit Rückfrage am Eintrag)
- **Lokale Speicherung** als JSON im Documents-Ordner
- **PDF-Export** (mehrseitig bei Bedarf) mit Tagesübersicht; Teilen über das System-Dialogfeld
- **Deutsche Datumsformate** in der App und im PDF
## Voraussetzungen
- Xcode (empfohlen: aktuelle stabile Version)
- **Deployment Target:** iOS **16.0**
- Keine externen Abhängigkeiten
## Starten
1. Repository klonen oder entpacken  
2. `Zeiterfassung.xcodeproj` in Xcode öffnen  
3. Ziel **Simulator** oder **Gerät** wählen  
4. **Run** (⌘R)
## Projektstruktur (Auszug)
| Datei / Bereich | Rolle |
|-----------------|--------|
| `TimeEntry.swift` | Datenmodell (`Codable`) |
| `TimeStore.swift` | Zustand, Logik, Persistenz |
| `ContentView.swift` | Haupt-UI |
| `AllEntriesView.swift` | Liste aller Einträge, PDF-Export |
| `ManualEntrySheet.swift` | Formular für manuelle Zeiten |
| `TimeReportView.swift` / `PDFExporter.swift` | PDF-Layout und -Erzeugung |
## Hinweis
Private **Lern-/Projektarbeits**-Basis; Bundle-ID und Signierung in Xcode bei Bedarf anpassen.
Die Datei README.md liegt im Projektroot. Sie enthält:

Kurzbeschreibung und Technologie-Stack
Aufzählung der wichtigsten Funktionen
Voraussetzungen (Xcode, iOS 16, keine Dependencies)
Drei Schritte zum Starten in Xcode
Kleine Tabelle zur Code-Struktur
Hinweis auf privates Nutzungs-/Lernprojekt
Wenn du Lizenz, Screenshots oder einen englischen Abschnitt ergänzen willst, sag kurz Bescheid.