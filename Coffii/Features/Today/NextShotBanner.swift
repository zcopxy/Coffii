import SwiftUI

/// The pinned "what to try next" note for a bean, shown on Today as a banner.
struct NextShotBanner: View {
    let bean: Bean
    let note: String

    var body: some View {
        NavigationLink(value: bean) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Palette.cremaSoft.opacity(0.45))
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Palette.crema)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text("NEXT SHOT")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1.3)
                        .textCase(.uppercase)
                        .foregroundStyle(Palette.inkSoft)
                    Text(note)
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.inkSoft)
            }
            .padding(16)
            .background(Palette.paper)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.cremaSoft.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
