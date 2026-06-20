import SwiftUI
import UIKit

/// Wraps `ImageRenderer` to export the card at share resolutions. The view is
/// already laid out at pixel size, so `scale = 1` yields exact 1080-wide output.
enum CardRenderer {
    @MainActor
    static func render(shot: Shot, theme: CardTheme = .warmEditorial, size: CardSize) -> UIImage? {
        let view = ShotCardView(shot: shot, theme: theme, size: size)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        renderer.isOpaque = false
        return renderer.uiImage
    }
}
