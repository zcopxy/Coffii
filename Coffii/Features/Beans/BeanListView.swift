import SwiftUI
import SwiftData

struct BeanListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Bean.createdAt, order: .reverse) private var beans: [Bean]
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if beans.isEmpty {
                        emptyState
                    } else {
                        ForEach(beans) { bean in
                            NavigationLink(value: bean) { beanRow(bean) }
                                .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            .background(Palette.cream.ignoresSafeArea())
            .navigationTitle("Beans")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus").font(.system(.headline, weight: .semibold))
                    }
                }
            }
            .navigationDestination(for: Bean.self) { BeanDetailView(bean: $0) }
        }
        .sheet(isPresented: $showAdd) { BeanEditView(bean: nil) }
    }

    private func beanRow(_ bean: Bean) -> some View {
        WarmCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Palette.cremaSoft.opacity(0.5))
                    Image(systemName: EspressoIcon.bag)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Palette.crema)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(bean.displayName).font(.system(.headline, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                        if bean.isFavorite {
                            Image(systemName: EspressoIcon.star)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Palette.crema)
                        }
                    }
                    HStack(spacing: 8) {
                        if let d = bean.daysOffRoast {
                            Text("\(d)d off roast").eyebrow(.caption2)
                        }
                        Text("\(bean.shots.count) shots").eyebrow(.caption2)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkSoft)
            }
        }
    }

    private var emptyState: some View {
        WarmCard {
            VStack(spacing: 12) {
                Image(systemName: EspressoIcon.bag)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Palette.crema)
                Text("No beans yet")
                    .serifTitle(.headline)
                    .foregroundStyle(Palette.espresso)
                Text("Add a bean to start logging shots against it.")
                    .font(.system(.subheadline))
                    .foregroundStyle(Palette.inkSoft)
                    .multilineTextAlignment(.center)
                PrimaryButton("Add a bean", systemImage: "plus") { showAdd = true }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    BeanListView()
        .modelContainer(for: [Shot.self, Bean.self, Grinder.self, Machine.self, Basket.self], inMemory: true)
}
