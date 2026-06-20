import Foundation

/// SwiftData `@Model` classes aren't `Identifiable` by default. Expose the
/// stable `uid` so models work with `.sheet(item:)`, `ForEach`, and navigation.
extension Bean: Identifiable    { var id: UUID { uid } }
extension Shot: Identifiable    { var id: UUID { uid } }
extension Grinder: Identifiable { var id: UUID { uid } }
extension Machine: Identifiable { var id: UUID { uid } }
extension Basket: Identifiable  { var id: UUID { uid } }
