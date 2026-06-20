import Foundation
import SwiftData

@Model
final class Shot {
    @Attribute(.unique) var uid: UUID
    var timestamp: Date
    var dose: Double
    var yield: Double
    var brewSeconds: Int
    var grindSetting: String
    var tempC: Double
    var preInfusionSeconds: Int?
    var pressureBar: Double?
    var tasteNote: String?
    var rating: Int?
    var tasteTags: [TasteTag]
    var photoData: Data?
    var isGoodPull: Bool

    var bean: Bean?
    var grinder: Grinder?
    var machine: Machine?
    var basket: Basket?

    init(
        timestamp: Date = .now,
        dose: Double = 18,
        yield: Double = 36,
        brewSeconds: Int = 28,
        grindSetting: String = "",
        tempC: Double = 93,
        preInfusionSeconds: Int? = nil,
        pressureBar: Double? = nil,
        tasteNote: String? = nil,
        rating: Int? = nil,
        tasteTags: [TasteTag] = [],
        photoData: Data? = nil,
        isGoodPull: Bool = false,
        bean: Bean? = nil,
        grinder: Grinder? = nil,
        machine: Machine? = nil,
        basket: Basket? = nil
    ) {
        self.uid = UUID()
        self.timestamp = timestamp
        self.dose = dose
        self.yield = yield
        self.brewSeconds = brewSeconds
        self.grindSetting = grindSetting
        self.tempC = tempC
        self.preInfusionSeconds = preInfusionSeconds
        self.pressureBar = pressureBar
        self.tasteNote = tasteNote
        self.rating = rating
        self.tasteTags = tasteTags
        self.photoData = photoData
        self.isGoodPull = isGoodPull
        self.bean = bean
        self.grinder = grinder
        self.machine = machine
        self.basket = basket
    }

    // MARK: - Computed (not stored)

    var ratio: Double { dose > 0 ? yield / dose : 0 }

    var flowRate: Double { brewSeconds > 0 ? yield / Double(brewSeconds) : 0 }

    var daysOffRoast: Int? { bean?.daysOffRoast }

    // MARK: - Formatting

    var ratioText: String {
        let r = ratio
        guard r > 0 else { return "—" }
        return String(format: "1:%.1f", r)
    }

    var doseText: String { Formatters.grams(dose) }
    var yieldText: String { Formatters.grams(yield) }
    var timeText: String { "\(brewSeconds)s" }
    var tempText: String { Formatters.temp(tempC) }
    var flowText: String { Formatters.flow(flowRate) }

    var primaryTasteTag: TasteTag? {
        tasteTags.first(where: { $0.isPositive }) ?? tasteTags.first
    }
}

enum Formatters {
    static func grams(_ v: Double) -> String {
        let s = String(format: "%.1f", v)
        return s.hasSuffix(".0") ? "\(s.dropLast(2))g" : "\(s)g"
    }

    static func temp(_ v: Double) -> String {
        "\(Int(v.rounded()))°"
    }

    static func flow(_ v: Double) -> String {
        String(format: "%.1fg/s", v)
    }
}
