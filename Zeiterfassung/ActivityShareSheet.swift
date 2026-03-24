import SwiftUI
import UIKit

/// Zeigt das System-Teilen-Dialogfeld fuer eine exportierte Datei (z. B. PDF).
struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        guard let popover = uiViewController.popoverPresentationController else { return }
        popover.sourceView = uiViewController.view
        let b = uiViewController.view.bounds
        popover.sourceRect = CGRect(x: b.midX, y: b.maxY, width: 0, height: 0)
        popover.permittedArrowDirections = []
    }
}
