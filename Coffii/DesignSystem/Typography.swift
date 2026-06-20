import SwiftUI

enum Typography {
    static let eyebrowTracking: CGFloat = 1.5

    static func serif(_ style: Font.TextStyle) -> Font {
        .system(style, design: .serif)
    }
}

extension View {
    /// Uppercase, tracked, secondary-color label — the "eyebrow" over sections and stats.
    func eyebrow(_ size: Font.TextStyle = .caption) -> some View {
        self
            .font(.system(size, weight: .semibold))
            .tracking(Typography.eyebrowTracking)
            .textCase(.uppercase)
            .foregroundStyle(Palette.inkSoft)
    }

    /// Serif (New York) headline.
    func serifTitle(_ style: Font.TextStyle = .title) -> some View {
        self.font(.system(style, design: .serif))
    }

    /// Tabular numerals for dose/yield/ratio/time so live values don't jitter.
    func tabularNumbers() -> some View {
        self.monospacedDigit()
    }

    /// Cream app background applied under a screen.
    func appBackground() -> some View {
        self
            .background(Palette.cream.ignoresSafeArea())
    }
}
