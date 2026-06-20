import SwiftUI
import UIKit

/// The single most important asset — product, ad, and ASO hero. Renders
/// beautifully from data alone; photo is an optional enhancement, never a gate.
struct ShotCardView: View {
    let shot: Shot
    var theme: CardTheme = .warmEditorial
    var size: CardSize = .preview

    var body: some View {
        let canvas = size.canvas
        switch size {
        case .preview:
            GeometryReader { geo in
                let scale = geo.size.width / canvas.width
                CardContent(shot: shot, theme: theme, canvas: canvas)
                    .frame(width: canvas.width, height: canvas.height)
                    .scaleEffect(scale, anchor: .topLeading)
                    .frame(width: geo.size.width, height: geo.size.width * canvas.height / canvas.width)
            }
            .aspectRatio(canvas.width / canvas.height, contentMode: .fit)
        case .stories, .square:
            CardContent(shot: shot, theme: theme, canvas: canvas)
                .frame(width: canvas.width, height: canvas.height)
        }
    }
}

private struct CardContent: View {
    let shot: Shot
    let theme: CardTheme
    let canvas: CGSize

    private var w: CGFloat { canvas.width }
    private var h: CGFloat { canvas.height }
    private var pad: CGFloat { w * 0.072 }

    var body: some View {
        ZStack {
            theme.background

            VStack(alignment: .leading, spacing: 0) {
                header
                beanLine
                    .padding(.top, h * 0.018)

                if let photo = photoImage {
                    photoStrip(photo)
                        .padding(.top, h * 0.028)
                }

                Spacer(minLength: h * 0.03)

                heroStats
                secondaryStats
                    .padding(.top, h * 0.034)

                if let note = shot.tasteNote, !note.isEmpty {
                    tasteQuote(note)
                        .padding(.top, h * 0.038)
                }

                if !shot.tasteTags.isEmpty {
                    tagRow
                        .padding(.top, h * 0.03)
                }

                Spacer(minLength: h * 0.04)

                cremaBand
                footer
                    .padding(.top, h * 0.022)
            }
            .padding(pad)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .overlay(
            RoundedRectangle(cornerRadius: w * 0.018, style: .continuous)
                .stroke(theme.accentSoft.opacity(0.5), lineWidth: max(1, w * 0.0015))
        )
        .clipShape(RoundedRectangle(cornerRadius: w * 0.018, style: .continuous))
    }

    // MARK: - Pieces

    private var header: some View {
        VStack(alignment: .leading, spacing: w * 0.012) {
            HStack(spacing: w * 0.014) {
                Text("Shot in Review")
                    .font(.system(size: w * 0.030, weight: .semibold, design: .serif))
                    .tracking(0.5)
                    .foregroundStyle(theme.ink)
                Spacer()
                if shot.isGoodPull {
                    Image(systemName: EspressoIcon.star)
                        .font(.system(size: w * 0.024, weight: .bold))
                        .foregroundStyle(theme.accent)
                }
            }
            Text("COFFII · SHOT LOG")
                .font(.system(size: w * 0.018, weight: .semibold))
                .tracking(2.2)
                .textCase(.uppercase)
                .foregroundStyle(theme.accent)
            Rectangle().fill(theme.line).frame(height: 1.5)
        }
    }

    private var beanLine: some View {
        VStack(alignment: .leading, spacing: w * 0.010) {
            Text(shot.bean?.displayName ?? "Unknown bean")
                .font(.system(size: w * 0.044, weight: .semibold, design: .serif))
                .foregroundStyle(theme.ink)
                .lineLimit(2)
            HStack(spacing: w * 0.018) {
                if let level = shot.bean?.roastLevel {
                    metaChip(level.label)
                }
                if let d = shot.daysOffRoast {
                    metaChip("\(d) days off roast")
                }
                if let grinder = shot.grinder, !grinder.name.isEmpty {
                    metaChip(grinder.name)
                }
            }
        }
    }

    private func metaChip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: w * 0.0175, weight: .semibold))
            .tracking(1.2)
            .textCase(.uppercase)
            .foregroundStyle(theme.inkSoft)
    }

    private func photoStrip(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: h * 0.30)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: w * 0.02, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: w * 0.02, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )
    }

    private var heroStats: some View {
        HStack(alignment: .firstTextBaseline, spacing: w * 0.022) {
            statNumber(shot.doseText)
            arrow
            statNumber(shot.yieldText)
            Spacer(minLength: w * 0.04)
            VStack(alignment: .trailing, spacing: w * 0.004) {
                Text(shot.ratioText)
                    .font(.system(size: w * 0.072, weight: .semibold, design: .serif))
                    .tabularNumbers()
                    .foregroundStyle(theme.accent)
                Text("RATIO")
                    .eyebrowLabel(size: w * 0.016, color: theme.inkSoft)
            }
        }
    }

    private func statNumber(_ value: String) -> some View {
        Text(value)
            .font(.system(size: w * 0.082, weight: .semibold, design: .serif))
            .tabularNumbers()
            .foregroundStyle(theme.ink)
    }

    private var arrow: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: w * 0.038, weight: .bold))
            .foregroundStyle(theme.accent)
    }

    private var secondaryStats: some View {
        HStack(spacing: w * 0.05) {
            chipStat(glyph: EspressoIcon.timer, label: "TIME", value: shot.timeText)
            chipStat(glyph: "thermometer", label: "TEMP", value: shot.tempText)
            if shot.flowRate > 0 {
                chipStat(glyph: "drop.fill", label: "FLOW", value: shot.flowText)
            }
            Spacer(minLength: 0)
        }
    }

    private func chipStat(glyph: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: w * 0.008) {
            HStack(spacing: w * 0.006) {
                Image(systemName: glyph)
                    .font(.system(size: w * 0.014, weight: .semibold))
                    .foregroundStyle(theme.accent)
                Text(label)
                    .eyebrowLabel(size: w * 0.016, color: theme.inkSoft)
            }
            Text(value)
                .font(.system(size: w * 0.034, weight: .semibold, design: .serif))
                .tabularNumbers()
                .foregroundStyle(theme.ink)
        }
    }

    private func tasteQuote(_ note: String) -> some View {
        HStack(alignment: .top, spacing: w * 0.012) {
            Text("“")
                .font(.system(size: w * 0.06, weight: .semibold, design: .serif))
                .foregroundStyle(theme.accentSoft)
            Text(note)
                .font(.system(size: w * 0.028, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(theme.ink)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var tagRow: some View {
        HStack(spacing: w * 0.012) {
            ForEach(shot.tasteTags.prefix(4)) { tag in
                Text(tag.label)
                    .font(.system(size: w * 0.017, weight: .semibold))
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundStyle(tag.isPositive ? theme.background : theme.inkSoft)
                    .padding(.horizontal, w * 0.018)
                    .padding(.vertical, w * 0.009)
                    .background(tag.isPositive ? theme.accent : theme.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(theme.line, lineWidth: tag.isPositive ? 0 : 1))
            }
            Spacer(minLength: 0)
        }
    }

    private var cremaBand: some View {
        LinearGradient(
            colors: [theme.accent.opacity(0), theme.accent, theme.accentSoft, theme.accent.opacity(0)],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(height: w * 0.006)
        .clipShape(Capsule())
    }

    private var footer: some View {
        HStack {
            Text(shot.timestamp, format: .dateTime.month(.wide).day().year())
                .font(.system(size: w * 0.016, weight: .semibold))
                .foregroundStyle(theme.inkSoft)
            Spacer()
            Text("ⓒ Coffii")
                .font(.system(size: w * 0.016, weight: .semibold))
                .foregroundStyle(theme.inkSoft)
        }
    }

    // MARK: - Helpers

    private var photoImage: UIImage? {
        guard let data = shot.photoData else { return nil }
        return UIImage(data: data)
    }
}

private extension View {
    func eyebrowLabel(size: CGFloat, color: Color) -> some View {
        self
            .font(.system(size: size, weight: .semibold))
            .tracking(1.4)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ShotCardView(shot: Shot(dose: 18, yield: 36, brewSeconds: 28, tempC: 93, tasteNote: "Sweet, balanced, syrupy body.", isGoodPull: true), size: .preview)
                .frame(height: 480)
        }
        .padding(20)
    }
    .appBackground()
    .modelContainer(for: [Shot.self, Bean.self, Grinder.self, Machine.self, Basket.self], inMemory: true)
}
