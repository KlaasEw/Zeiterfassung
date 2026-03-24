import SwiftUI

@main
struct ZeiterfassungApp: App {
    @StateObject private var store = TimeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environment(\.locale, Locale(identifier: "de_DE"))
        }
    }
}
