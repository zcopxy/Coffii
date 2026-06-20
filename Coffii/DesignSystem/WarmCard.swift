import SwiftUI

/// Paper card, 16pt continuous corners, hairline border, soft shadow.
struct WarmCard<Content: View>: View {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(Palette.paper)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Palette.line, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

extension WarmCard where Content == EmptyView {
    init(padding: CGFloat = 20, cornerRadius: CGFloat = 16) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = { EmptyView() }
    }
}

#Preview {
    WarmCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shot in Review").serifTitle(.title2)
            Text("18g → 36g · 1:2.0 · 28s").tabularNumbers()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(24)
    .appBackground()
}
