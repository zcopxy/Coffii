import SwiftUI

/// Warm Editorial color tokens, asset-backed (light + dark variants live in
/// Assets.xcassets). Reference as `Palette.crema` or the `.crema` shorthand.
enum Palette {
    static let cream     = Color("Cream")
    static let paper     = Color("Paper")
    static let ink       = Color("Ink")
    static let inkSoft   = Color("InkSoft")
    static let espresso  = Color("Espresso")
    static let crema     = Color("Crema")
    static let cremaSoft = Color("CremaSoft")
    static let line      = Color("Line")
    static let good      = Color("Good")
    static let warn      = Color("Warn")
}

extension Color {
    static let cream     = Palette.cream
    static let paper     = Palette.paper
    static let ink       = Palette.ink
    static let inkSoft   = Palette.inkSoft
    static let espresso  = Palette.espresso
    static let crema     = Palette.crema
    static let cremaSoft = Palette.cremaSoft
    static let line      = Palette.line
    static let good      = Palette.good
    static let warn      = Palette.warn
}
