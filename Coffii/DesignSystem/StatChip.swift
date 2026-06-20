import SwiftUI

/// Label + tabular value — the building block of the 18g→36g / 1:2.0 / 28s / 93° row.
struct StatChip: View {
    let label: String
    let value: String
    var glyph: String? = nil
    var accent: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                if let glyph {
                    Image(systemName: glyph)
                        .font(.system(size: 10, weight: .semibold))
                }
                Text(label).eyebrow(.caption2)
            }
            Text(value)
                .font(.system(.title3, design: .serif, weight: .semibold))
                .tabularNumbers()
                .foregroundStyle(accent ? Palette.crema : Palette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StatRow<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        HStack(alignment: .top, spacing: 16) { content() }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    WarmCard {
        StatRow {
            StatChip(label: "Dose", value: "18g")
            StatChip(label: "Yield", value: "36g")
            StatChip(label: "Ratio", value: "1:2.0", accent: true)
            StatChip(label: "Time", value: "28s", glyph: "timer")
            StatChip(label: "Temp", value: "93°", glyph: "thermometer")
        }
    }
    .padding(24)
    .appBackground()
}
