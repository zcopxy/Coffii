import SwiftUI

/// Minimal Settings for v1. Pro paywall, export, and card-theme picker land in Phase 5.
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    brandCard
                    privacyCard
                    proCard
                    aboutCard
                }
                .padding(16)
            }
            .background(Palette.cream.ignoresSafeArea())
            .navigationTitle("Settings")
        }
    }

    private var brandCard: some View {
        WarmCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Palette.crema)
                    Image(systemName: EspressoIcon.cup)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Palette.paper)
                }
                .frame(width: 52, height: 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Coffii").serifTitle(.title3).foregroundStyle(Palette.espresso)
                    Text("An espresso-only shot log.").font(.system(.subheadline)).foregroundStyle(Palette.inkSoft)
                }
                Spacer()
            }
        }
    }

    private var privacyCard: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Private by design", systemImage: "lock.fill")
                    .font(.system(.headline, weight: .semibold))
                    .foregroundStyle(Palette.espresso)
                Text("Your shots never leave your phone. No account, no cloud, no tracking. Export your data anytime — it's yours.")
                    .font(.system(.subheadline))
                    .foregroundStyle(Palette.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var proCard: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Coffii Pro", systemImage: "star.fill")
                    .font(.system(.headline, weight: .semibold))
                    .foregroundStyle(Palette.crema)
                Text("Charts, diff cards, and custom card themes — coming soon. Logging, the timer, and the standard Shot in Review card are free forever.")
                    .font(.system(.subheadline))
                    .foregroundStyle(Palette.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var aboutCard: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Version 1.0").eyebrow(.caption2)
                Text("Built for home baristas.").font(.system(.subheadline)).foregroundStyle(Palette.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SettingsView()
}
