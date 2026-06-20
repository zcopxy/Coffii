import UIKit

/// Thin wrapper over UIKit feedback generators. Kept deliberately tiny —
/// the spec's motion discipline: haptics on shot start/stop and target ticks.
enum HapticEngine {
    static func startPull()    { impact(.medium) }
    static func stopPull()     { notify(.success) }
    static func targetTick()   { impact(.light) }
    static func selection()    { selectionChanged() }
    static func saveSuccess()  { notify(.success) }
    static func warning()      { notify(.warning) }

    private static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard !ProcessInfo.processInfo.isLowPowerModeEnabled else { return }
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.prepare()
        gen.impactOccurred()
    }

    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(type)
    }

    private static func selectionChanged() {
        let gen = UISelectionFeedbackGenerator()
        gen.prepare()
        gen.selectionChanged()
    }
}
