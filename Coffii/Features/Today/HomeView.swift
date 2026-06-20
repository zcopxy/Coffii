import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Shot.timestamp, order: .reverse) private var allShots: [Shot]
    @Query(sort: \Bean.createdAt, order: .reverse) private var beans: [Bean]

    @State private var showLog = false
    @State private var prefillShot: Shot?
    @State private var revealShot: Shot?
    @State private var shareExistingShot: Shot?

    private var lastGoodPull: Shot? { allShots.first(where: { $0.isGoodPull }) }
    private var lastShot: Shot? { allShots.first }
    private var recentShots: [Shot] { Array(allShots.prefix(8)) }
    private var nextShotBean: Bean? {
        lastGoodPull?.bean ?? lastShot?.bean ?? beans.first
    }
    private var restingBeans: [Bean] {
        beans.filter { bean in
            guard let days = bean.daysOffRoast else { return false }
            return days >= 0 && days < 7
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    lastGoodPullSection
                    if let bean = nextShotBean, let note = bean.nextShotNote, !note.isEmpty {
                        NextShotBanner(bean: bean, note: note)
                    }
                    primaryActions
                    if !restingBeans.isEmpty { restingReminder }
                    if !recentShots.isEmpty { recentSection }
                    Spacer(minLength: 12)
                }
                .padding(16)
            }
            .background(Palette.cream.ignoresSafeArea())
            .navigationTitle("Today")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { totalBadge } }
            .navigationDestination(for: Bean.self) { BeanDetailView(bean: $0) }
            .sheet(isPresented: $showLog, onDismiss: { prefillShot = nil }) {
                LogShotView(prefill: prefillShot) { shot in
                    showLog = false
                    revealShot = shot
                }
            }
            .sheet(item: $revealShot) { CardRevealView(shot: $0) }
            .sheet(item: $shareExistingShot) { CardRevealView(shot: $0) }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var lastGoodPullSection: some View {
        if let lastGoodPull {
            LastGoodPullCard(shot: lastGoodPull) {
                shareExistingShot = lastGoodPull
            }
        } else {
            LastGoodPullEmpty { startLogging(prefill: nil) }
        }
    }

    private var primaryActions: some View {
        VStack(spacing: 10) {
            PrimaryButton("Pull a shot", systemImage: EspressoIcon.cup) { startLogging(prefill: nil) }
            SecondaryButton("Re-log last shot", systemImage: "arrow.clockwise") {
                if let lastShot { startLogging(prefill: lastShot) }
            }
            .disabled(lastShot == nil)
            .opacity(lastShot == nil ? 0.4 : 1)
        }
    }

    private var restingReminder: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("Resting", systemImage: "moon.fill")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(Palette.crema)
                ForEach(restingBeans) { bean in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(bean.displayName)
                                .font(.system(.subheadline, weight: .semibold))
                                .foregroundStyle(Palette.ink)
                            if let d = bean.daysOffRoast {
                                Text("Day \(d) of 7 — let it rest a little longer.")
                                    .font(.system(.caption))
                                    .foregroundStyle(Palette.inkSoft)
                            }
                        }
                        Spacer()
                    }
                    if bean.uid != restingBeans.last?.uid {
                        Divider().background(Palette.line)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var recentSection: some View {
        WarmCard(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent").eyebrow().padding(.horizontal, 8).padding(.top, 4)
                ForEach(recentShots) { shot in
                    rowLink(for: shot)
                    if shot.uid != recentShots.last?.uid {
                        Divider().background(Palette.line)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func rowLink(for shot: Shot) -> some View {
        let row = ShotRow(shot: shot)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .contentShape(RoundedRectangle(cornerRadius: 10))
        if let bean = shot.bean {
            NavigationLink(value: bean) { row }
                .buttonStyle(.plain)
        } else {
            row
        }
    }

    private var totalBadge: some View {
        Text("\(allShots.count) shots")
            .font(.system(.caption, weight: .semibold))
            .foregroundStyle(Palette.inkSoft)
    }

    // MARK: - Actions

    private func startLogging(prefill: Shot?) {
        prefillShot = prefill
        showLog = true
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Shot.self, Bean.self, Grinder.self, Machine.self, Basket.self], inMemory: true)
}
