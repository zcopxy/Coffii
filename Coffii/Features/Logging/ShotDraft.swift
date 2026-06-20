import Foundation

/// In-progress shot being logged. A single `@Observable` draft — no global store.
@Observable
final class ShotDraft {
    var bean: Bean?
    var grinder: Grinder?
    var machine: Machine?
    var basket: Basket?

    var dose: Double = 18
    var yield: Double = 36
    var brewSeconds: Int = 28
    var grindSetting: String = ""
    var tempC: Double = 93

    var preInfusionSeconds: Int?
    var pressureBar: Double?

    var tasteNote: String = ""
    var rating: Int?
    var tasteTags: [TasteTag] = []
    var photoData: Data?

    var isGoodPull: Bool = false
    var showsAdvanced: Bool = false

    var ratio: Double { dose > 0 ? yield / dose : 0 }
    var ratioText: String {
        let r = ratio
        guard r > 0 else { return "1:—" }
        return String(format: "1:%.1f", r)
    }

    /// Pre-fill from a previous shot (the "re-log last shot" one-tap path).
    func populate(from shot: Shot) {
        bean = shot.bean
        grinder = shot.grinder
        machine = shot.machine
        basket = shot.basket
        dose = shot.dose
        yield = shot.yield
        brewSeconds = shot.brewSeconds
        grindSetting = shot.grindSetting
        tempC = shot.tempC
        preInfusionSeconds = shot.preInfusionSeconds
        pressureBar = shot.pressureBar
        tasteNote = shot.tasteNote ?? ""
        rating = shot.rating
        tasteTags = shot.tasteTags
        photoData = nil
        isGoodPull = false
    }

    /// Default gear + bean to whatever was used most recently (the spec's
    /// "remembered" pickers), without overwriting an explicit prefill.
    func applyDefaults(from lastShot: Shot?) {
        guard let lastShot else { return }
        if bean == nil     { bean = lastShot.bean }
        if grinder == nil  { grinder = lastShot.grinder }
        if machine == nil  { machine = lastShot.machine }
        if basket == nil   { basket = lastShot.basket }
    }
}
