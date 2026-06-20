import SwiftUI

/// A single selectable taste-tag pill.
struct TasteTagToggle: View {
    let tag: TasteTag
    let isOn: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 6) {
                Image(systemName: tag.glyph)
                    .font(.system(size: 12, weight: .semibold))
                Text(tag.label)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .foregroundStyle(isOn ? Palette.paper : Palette.inkSoft)
            .background(isOn ? pillBackground : Palette.paper)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Palette.line, lineWidth: isOn ? 0 : 1))
        }
        .buttonStyle(.plain)
    }

    private var pillBackground: Color {
        tag.isPositive ? Palette.good : Palette.crema
    }
}

/// Full set of taste-tag pills bound to a selection.
struct TasteTagPicker: View {
    @Binding var selection: [TasteTag]

    var body: some View {
        FlowHStack(items: TasteTag.allCases) { tag in
            TasteTagToggle(tag: tag, isOn: selection.contains(tag)) {
                if selection.contains(tag) {
                    selection.removeAll { $0 == tag }
                } else {
                    selection.append(tag)
                }
            }
        }
    }
}

/// Simple wrapping layout for pills. Good enough for a fixed tag set.
struct FlowHStack<Item: Hashable, Content: View>: View {
    let items: [Item]
    @ViewBuilder var content: (Item) -> Content

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 110), spacing: 8, alignment: .leading)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { content($0) }
        }
    }
}

#Preview {
    @Previewable @State var tags: [TasteTag] = [.balanced]
    return TasteTagPicker(selection: $tags)
        .padding(24)
        .appBackground()
}
