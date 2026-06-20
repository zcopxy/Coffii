import SwiftUI

/// A card theme is a palette + a few layout flags. Warm Editorial ships free;
/// extra themes are the Pro cosmetic upsell (Phase 5). Designing the layout to
/// be theme-driven means the Pro upsell is a struct swap, not a reimplementation.
struct CardTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let background: Color
    let surface: Color
    let ink: Color
    let inkSoft: Color
    let accent: Color
    let accentSoft: Color
    let line: Color
    let isPro: Bool

    static let warmEditorial = CardTheme(
        id: "warm-editorial",
        name: "Warm Editorial",
        background: .cream,
        surface: .paper,
        ink: .ink,
        inkSoft: .inkSoft,
        accent: .crema,
        accentSoft: .cremaSoft,
        line: .line,
        isPro: false
    )
}

/// Export / preview geometries. The on-screen `.preview` mirrors the 4:5
/// Instagram portrait crop — the most common organic share shape.
enum CardSize: Hashable {
    case stories          // 1080 x 1920
    case square           // 1080 x 1080
    case preview          // 1080 x 1350 (4:5), scaled to container width

    var canvas: CGSize {
        switch self {
        case .stories: CGSize(width: 1080, height: 1920)
        case .square:  CGSize(width: 1080, height: 1080)
        case .preview: CGSize(width: 1080, height: 1350)
        }
    }
}
