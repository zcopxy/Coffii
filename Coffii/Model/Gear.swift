import Foundation
import SwiftData

/// Common surface for the three gear types so pickers can be generic.
protocol GearLike: PersistentModel {
    var pickerLabel: String { get }
}

extension Grinder: GearLike {
    var pickerLabel: String { name.isEmpty ? "Grinder" : name }
}
extension Machine: GearLike {
    var pickerLabel: String { name.isEmpty ? "Machine" : name }
}
extension Basket: GearLike {
    var pickerLabel: String {
        let size = Formatters.grams(sizeGrams)
        return brand.isEmpty ? "Basket · \(size)" : "\(brand) · \(size)"
    }
}

@Model
final class Grinder {
    @Attribute(.unique) var uid: UUID
    var name: String
    var burrType: String?
    var isStepless: Bool
    var notes: String
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \Shot.grinder)
    var shots: [Shot] = []

    init(name: String = "", burrType: String? = nil, isStepless: Bool = false, notes: String = "") {
        self.uid = UUID()
        self.name = name
        self.burrType = burrType
        self.isStepless = isStepless
        self.notes = notes
    }
}

@Model
final class Machine {
    @Attribute(.unique) var uid: UUID
    var name: String
    var type: String?
    var notes: String
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \Shot.machine)
    var shots: [Shot] = []

    init(name: String = "", type: String? = nil, notes: String = "") {
        self.uid = UUID()
        self.name = name
        self.type = type
        self.notes = notes
    }
}

@Model
final class Basket {
    @Attribute(.unique) var uid: UUID
    var sizeGrams: Double
    var brand: String
    var isPressurized: Bool
    var notes: String
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \Shot.basket)
    var shots: [Shot] = []

    init(sizeGrams: Double = 18, brand: String = "", isPressurized: Bool = false, notes: String = "") {
        self.uid = UUID()
        self.sizeGrams = sizeGrams
        self.brand = brand
        self.isPressurized = isPressurized
        self.notes = notes
    }
}
