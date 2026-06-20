import SwiftUI
import SwiftData

/// Minimal per-bean detail for v1: header, pinned next-shot note, history list.
/// Swift Charts and the diff card land in Phase 4.
struct BeanDetailView: View {
    @Bindable var bean: Bean
    @Environment(\.modelContext) private var context
    @State private var showEdit = false

    private var shots: [Shot] { bean.shotsChronological }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                header
                nextShotNoteCard
                if shots.isEmpty {
                    emptyHistory
                } else {
                    historyCard
                }
            }
            .padding(16)
        }
        .background(Palette.cream.ignoresSafeArea())
        .navigationTitle("Bean")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showEdit = true } label: {
                    Image(systemName: "pencil").font(.system(.headline, weight: .semibold))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    bean.isFavorite.toggle()
                    try? context.save()
                } label: {
                    Image(systemName: bean.isFavorite ? EspressoIcon.star : "star")
                        .foregroundStyle(bean.isFavorite ? Palette.crema : Palette.inkSoft)
                }
            }
        }
        .sheet(isPresented: $showEdit) { BeanEditView(bean: bean) }
    }

    private var header: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(bean.displayName).serifTitle(.title2).foregroundStyle(Palette.espresso)
                HStack(spacing: 10) {
                    if let r = bean.roastLevel { chip(r.label) }
                    if let p = bean.process, !p.isEmpty { chip(p) }
                    if let d = bean.daysOffRoast { chip("\(d) days off roast") }
                }
                if !bean.notes.isEmpty {
                    Text(bean.notes).font(.system(.subheadline)).foregroundStyle(Palette.inkSoft)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text).eyebrow(.caption2)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Palette.cream)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Palette.line, lineWidth: 1))
    }

    private var nextShotNoteCard: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Next shot note").eyebrow()
                TextField("e.g. go 1 finer, +2°", text: Binding(
                    get: { bean.nextShotNote ?? "" },
                    set: { bean.nextShotNote = $0.isEmpty ? nil : $0; try? context.save() }
                ), axis: .vertical)
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(Palette.ink)
                .lineLimit(1...3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var historyCard: some View {
        WarmCard(padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("History").eyebrow().padding(.horizontal, 8).padding(.top, 4)
                ForEach(shots) { shot in
                    ShotRow(shot: shot)
                        .padding(.vertical, 6)
                    if shot.uid != shots.last?.uid {
                        Divider().background(Palette.line)
                    }
                }
            }
        }
    }

    private var emptyHistory: some View {
        WarmCard {
            VStack(spacing: 8) {
                Text("No shots logged yet")
                    .serifTitle(.headline)
                    .foregroundStyle(Palette.espresso)
                Text("Pull your first shot from the Today tab.")
                    .font(.system(.subheadline)).foregroundStyle(Palette.inkSoft)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 8)
        }
    }
}

/// Compact row used in bean history and the Today recent list.
struct ShotRow: View {
    let shot: Shot

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(shot.timeText).font(.system(.subheadline, weight: .semibold)).tabularNumbers()
                    Text("·").foregroundStyle(Palette.inkSoft)
                    Text(shot.ratioText).font(.system(.subheadline, weight: .semibold)).tabularNumbers()
                        .foregroundStyle(Palette.crema)
                    if shot.isGoodPull {
                        Image(systemName: EspressoIcon.star).font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Palette.good)
                    }
                }
                if let note = shot.tasteNote, !note.isEmpty {
                    Text("\"\(note)\"")
                        .font(.system(.caption))
                        .foregroundStyle(Palette.inkSoft)
                        .lineLimit(1)
                }
            }
            Spacer()
            if let tag = shot.primaryTasteTag {
                Text(tag.label).eyebrow(.caption2)
            }
            Text(shot.timestamp, format: .dateTime.month().day())
                .font(.system(.caption2)).foregroundStyle(Palette.inkSoft)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    NavigationStack {
        BeanDetailView(bean: Bean(roaster: "Onyx", origin: "Monarch"))
    }
    .modelContainer(for: [Shot.self, Bean.self, Grinder.self, Machine.self, Basket.self], inMemory: true)
}
