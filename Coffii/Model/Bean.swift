import Foundation
import SwiftData

@Model
final class Bean {
    @Attribute(.unique) var uid: UUID
    var roaster: String
    var origin: String
    var process: String?
    var roastLevel: RoastLevel?
    var roastDate: Date?
    var notes: String
    var isFavorite: Bool
    var nextShotNote: String?
    var photoData: Data?
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Shot.bean)
    var shots: [Shot] = []

    init(
        roaster: String = "",
        origin: String = "",
        process: String? = nil,
        roastLevel: RoastLevel? = nil,
        roastDate: Date? = nil,
        notes: String = "",
        isFavorite: Bool = false,
        nextShotNote: String? = nil,
        photoData: Data? = nil
    ) {
        self.uid = UUID()
        self.roaster = roaster
        self.origin = origin
        self.process = process
        self.roastLevel = roastLevel
        self.roastDate = roastDate
        self.notes = notes
        self.isFavorite = isFavorite
        self.nextShotNote = nextShotNote
        self.photoData = photoData
    }

    var displayName: String {
        let parts = [roaster, origin].filter { !$0.isEmpty }
        return parts.isEmpty ? "Unknown bean" : parts.joined(separator: " · ")
    }

    var daysOffRoast: Int? {
        guard let roastDate else { return nil }
        return Calendar.current.dateComponents([.day], from: roastDate, to: .now).day
    }
}

extension Bean {
    /// Sorted descending by timestamp.
    var shotsChronological: [Shot] {
        shots.sorted { $0.timestamp > $1.timestamp }
    }

    var lastGoodPull: Shot? {
        shotsChronological.first(where: { $0.isGoodPull })
    }

    var lastShot: Shot? {
        shotsChronological.first
    }
}
