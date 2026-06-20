import SwiftUI
import SwiftData

@main
struct CoffiiApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Shot.self, Bean.self, Grinder.self, Machine.self, Basket.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
