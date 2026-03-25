# Projektzeiterfassung

Kleine **SwiftUI**-App (iOS 18+) zur privaten Zeiterfassung – ohne Cloud, ohne Backend. Dieses Projekt wurde vollständig von AI programiert.

|Ausgestempelt|Eingestempelt|
|---|---|
|![APP Sreenshot Ausgestempelt](/Assets/Zeiterfassung_Ausgestempelt.png)|![APP Screenshot Eingestempelt](/Assets/Zeiterfassung_Eingestempelt.png)|

## Funktionen

- **Ein-/Ausstempeln** mit Statusanzeige und optionalem Notizfeld
- **Manuelle Einträge** (Plus oben rechts): Anfang, Ende, Notiz
- **Letzte drei Einträge** auf der Startseite; **alle Einträge** gruppiert nach Tagen
- Einträge **bearbeiten** (Notiz), **löschen** (mit Rückfrage am Eintrag)
- **Lokale Speicherung** als JSON im Documents-Ordner
- **PDF-Export** (mehrseitig bei Bedarf) mit Tagesübersicht; Teilen über das System-Dialogfeld
- **Deutsche Datumsformate** in der App und im PDF

|Übersicht|Report|
|---|---|
|![APP Sreenshot Übersicht aller Einträge](/Assets/Uerbersicht_Alle_Einträge.png)|![PDF Reprot](/Assets/Report.png)|

## Voraussetzungen

- Xcode (empfohlen: aktuelle stabile Version)
- **Deployment Target:** iOS **18.6**
- Keine externen Abhängigkeiten

## Starten

1. Repository klonen oder entpacken
2. `Zeiterfassung.xcodeproj` in Xcode öffnen
3. Ziel **Simulator** oder **Gerät** wählen
4. **Run** (⌘R)

## Projektstruktur (Auszug)


| Datei / Bereich                              | Rolle                            |
| -------------------------------------------- | -------------------------------- |
| `TimeEntry.swift`                            | Datenmodell (`Codable`)          |
| `TimeStore.swift`                            | Zustand, Logik, Persistenz       |
| `ContentView.swift`                          | Haupt-UI                         |
| `AllEntriesView.swift`                       | Liste aller Einträge, PDF-Export |
| `ManualEntrySheet.swift`                     | Formular für manuelle Zeiten     |
| `TimeReportView.swift` / `PDFExporter.swift` | PDF-Layout und -Erzeugung        |
