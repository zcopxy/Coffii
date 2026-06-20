import SwiftUI

/// The payoff, always visible on Today: the last shot marked as a good pull,
/// rendered as a live Shot in Review card. Tap to re-share.
struct LastGoodPullCard: View {
    let shot: Shot
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Last good pull", systemImage: EspressoIcon.star)
                        .font(.system(.caption, weight: .semibold))
                        .tracking(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(Palette.crema)
                    Spacer()
                    Text("Tap to share")
                        .font(.system(.caption2, weight: .semibold))
                        .foregroundStyle(Palette.inkSoft)
                }
                ShotCardView(shot: shot, size: .preview)
            }
        }
        .buttonStyle(.plain)
    }
}

/// First-run / empty state when no good pull has been logged yet.
struct LastGoodPullEmpty: View {
    var onPull: () -> Void

    var body: some View {
        WarmCard {
            VStack(spacing: 12) {
                Image(systemName: EspressoIcon.cup)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Palette.crema)
                Text("Your Shot in Review lives here")
                    .serifTitle(.headline)
                    .foregroundStyle(Palette.espresso)
                    .multilineTextAlignment(.center)
                Text("Log a shot and mark it as a good pull — your last winner stays pinned here, ready to share.")
                    .font(.system(.subheadline))
                    .foregroundStyle(Palette.inkSoft)
                    .multilineTextAlignment(.center)
                PrimaryButton("Pull a shot", systemImage: EspressoIcon.cup, action: onPull)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
}
