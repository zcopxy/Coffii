import SwiftUI

struct RootView: View {
    @State private var selection: Tab = .today

    enum Tab: Hashable {
        case today, beans, settings
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label("Today", systemImage: "cup.and.saucer.fill") }
                .tag(Tab.today)

            BeanListView()
                .tabItem { Label("Beans", systemImage: "bag.fill") }
                .tag(Tab.beans)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .tint(.crema)
        .background(Palette.cream.ignoresSafeArea())
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Shot.self, Bean.self, Grinder.self, Machine.self, Basket.self], inMemory: true)
}
