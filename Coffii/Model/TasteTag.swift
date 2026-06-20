import Foundation

enum TasteTag: String, Codable, CaseIterable, Identifiable {
    case sour, bitter, balanced, channeling, hollow, ashy

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sour:        "Sour"
        case .bitter:      "Bitter"
        case .balanced:    "Balanced"
        case .channeling:  "Channeling"
        case .hollow:      "Hollow"
        case .ashy:        "Ashy"
        }
    }

    var glyph: String {
        switch self {
        case .sour:        "lemon.fill"
        case .bitter:      "leaf.fill"
        case .balanced:    "target.fill"
        case .channeling:  "drop.triangle.fill"
        case .hollow:      "circle.dashed"
        case .ashy:        "flame.fill"
        }
    }

    var isPositive: Bool { self == .balanced }
}

enum RoastLevel: String, Codable, CaseIterable, Identifiable {
    case light, mediumLight, medium, mediumDark, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .light:        "Light"
        case .mediumLight:  "Medium-Light"
        case .medium:       "Medium"
        case .mediumDark:   "Medium-Dark"
        case .dark:         "Dark"
        }
    }
}
