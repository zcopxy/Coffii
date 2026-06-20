import SwiftUI
import SwiftData

struct LogShotView: View {
    /// Non-nil when re-logging an existing shot (one-tap pre-fill).
    var prefill: Shot? = nil
    var onSaved: (Shot) -> Void = { _ in }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var draft = ShotDraft()
    @State private var didApplyDefaults = false

    @State private var showAddBean = false
    @State private var showAddGrinder = false
    @State private var showAddMachine = false
    @State private var showAddBasket = false
    @State private var showTimer = false

    @Query(sort: \Bean.createdAt, order: .reverse) private var beans: [Bean]
    @Query(sort: \Grinder.createdAt, order: .reverse) private var grinders: [Grinder]
    @Query(sort: \Machine.createdAt, order: .reverse) private var machines: [Machine]
    @Query(sort: \Basket.createdAt, order: .reverse) private var baskets: [Basket]
    @Query(sort: \Shot.timestamp, order: .reverse) private var recentShots: [Shot]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    beanSection
                    gearSection
                    doseYieldSection
                    timeGrindTempSection
                    tasteSection
                    photoSection
                    advancedSection
                    goodPullToggle
                    Spacer(minLength: 12)
                }
                .padding(16)
            }
            .background(Palette.cream.ignoresSafeArea())
            .navigationTitle("Log shot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .font(.system(.body, weight: .semibold))
                }
            }
            .onAppear { configureDraftIfNeeded() }
        }
        .sheet(isPresented: $showAddBean) {
            BeanEditView(bean: nil) { draft.bean = $0 }
        }
        .sheet(isPresented: $showAddGrinder) {
            GrinderEditView(grinder: nil) { draft.grinder = $0 }
        }
        .sheet(isPresented: $showAddMachine) {
            MachineEditView(machine: nil) { draft.machine = $0 }
        }
        .sheet(isPresented: $showAddBasket) {
            BasketEditView(basket: nil) { draft.basket = $0 }
        }
        .fullScreenCover(isPresented: $showTimer) {
            ShotTimerView { secs in draft.brewSeconds = secs }
        }
    }

    // MARK: - Draft setup

    private func configureDraftIfNeeded() {
        guard !didApplyDefaults else { return }
        didApplyDefaults = true
        if let prefill {
            draft.populate(from: prefill)
        } else {
            draft.applyDefaults(from: recentShots.first)
            if draft.bean == nil { draft.bean = beans.first }
            if draft.grinder == nil { draft.grinder = grinders.first }
            if draft.machine == nil { draft.machine = machines.first }
            if draft.basket == nil { draft.basket = baskets.first }
        }
    }

    // MARK: - Sections

    private var beanSection: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Bean").eyebrow()
                if beans.isEmpty {
                    HStack {
                        Text("Add your first bean to start logging.")
                            .font(.system(.subheadline))
                            .foregroundStyle(Palette.inkSoft)
                        Spacer()
                        SecondaryButton("Add bean", systemImage: "plus") { showAddBean = true }
                    }
                } else {
                    Menu {
                        Picker("Bean", selection: $draft.bean) {
                            Text("None").tag(Bean?.none)
                            ForEach(beans) { Text($0.displayName).tag(Bean?.some($0)) }
                        }
                        Divider()
                        Button("Add bean…") { showAddBean = true }
                    } label: {
                        beanLabel
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var beanLabel: some View {
        HStack(spacing: 12) {
            Image(systemName: EspressoIcon.bag)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Palette.crema)
            VStack(alignment: .leading, spacing: 2) {
                Text(draft.bean?.displayName ?? "Choose a bean")
                    .font(.system(.headline, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                if let d = draft.bean?.daysOffRoast {
                    Text("\(d) days off roast").eyebrow(.caption2)
                }
            }
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Palette.inkSoft)
        }
    }

    private var gearSection: some View {
        WarmCard {
            VStack(spacing: 12) {
                gearRow(title: "Grinder", icon: "circle.grid.2x1.fill",
                        selection: $draft.grinder, items: gridersPickerItems,
                        emptyName: "No grinder", onAdd: { showAddGrinder = true })
                Divider().background(Palette.line)
                gearRow(title: "Machine", icon: EspressoIcon.cup,
                        selection: $draft.machine, items: machinesPickerItems,
                        emptyName: "No machine", onAdd: { showAddMachine = true })
                Divider().background(Palette.line)
                gearRow(title: "Basket", icon: "circle.dashed",
                        selection: $draft.basket, items: basketsPickerItems,
                        emptyName: "No basket", onAdd: { showAddBasket = true })
            }
        }
    }

    private func gearRow<T: GearLike & Hashable>(
        title: String, icon: String,
        selection: Binding<T?>,
        items: AnyView,
        emptyName: String,
        onAdd: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Palette.crema)
                .frame(width: 22)
            Text(title).eyebrow(.caption)
            Spacer()
            Menu {
                items
                Divider()
                Button("Add \(title.lowercased())…") { onAdd() }
            } label: {
                HStack(spacing: 5) {
                    Text(selection.wrappedValue?.pickerLabel ?? emptyName)
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Palette.inkSoft)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var gridersPickerItems: AnyView {
        AnyView(
            Picker("Grinder", selection: $draft.grinder) {
                Text("None").tag(Grinder?.none)
                ForEach(grinders) { Text($0.name).tag(Grinder?.some($0)) }
            }
        )
    }
    private var machinesPickerItems: AnyView {
        AnyView(
            Picker("Machine", selection: $draft.machine) {
                Text("None").tag(Machine?.none)
                ForEach(machines) { Text($0.name).tag(Machine?.some($0)) }
            }
        )
    }
    private var basketsPickerItems: AnyView {
        AnyView(
            Picker("Basket", selection: $draft.basket) {
                Text("None").tag(Basket?.none)
                ForEach(baskets) { Text($0.pickerLabel).tag(Basket?.some($0)) }
            }
        )
    }

    // MARK: Dose / Yield

    private var doseYieldSection: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Recipe").eyebrow()
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(Formatters.grams(draft.dose))")
                        .font(.system(.title, design: .serif, weight: .semibold))
                        .tabularNumbers()
                        .foregroundStyle(Palette.ink)
                    Text("→")
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(Palette.inkSoft)
                    Text("\(Formatters.grams(draft.yield))")
                        .font(.system(.title, design: .serif, weight: .semibold))
                        .tabularNumbers()
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    Text(draft.ratioText)
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .tabularNumbers()
                        .foregroundStyle(Palette.crema)
                }
                stepperRow(label: "Dose", value: $draft.dose, range: 5...30, step: 0.1, suffix: "g")
                stepperRow(label: "Yield", value: $draft.yield, range: 5...80, step: 0.5, suffix: "g")
            }
        }
    }

    private func stepperRow(label: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, suffix: String) -> some View {
        HStack {
            Text(label).eyebrow(.caption)
            Spacer()
            Stepper(value: value, in: range, step: step) {
                Text(String(format: "%.1f\(suffix)", value.wrappedValue))
                    .font(.system(.body, weight: .semibold))
                    .tabularNumbers()
                    .foregroundStyle(Palette.ink)
            }
        }
    }

    // MARK: Time / Grind / Temp

    private var timeGrindTempSection: some View {
        WarmCard {
            VStack(spacing: 14) {
                HStack {
                    Text("Time").eyebrow(.caption)
                    Spacer()
                    Text("\(draft.brewSeconds)s")
                        .font(.system(.headline, weight: .semibold))
                        .tabularNumbers()
                        .foregroundStyle(Palette.ink)
                    Stepper(value: $draft.brewSeconds, in: 1...120) {
                        EmptyView()
                    }
                    .labelsHidden()
                    Button {
                        showTimer = true
                    } label: {
                        Image(systemName: EspressoIcon.timer)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Palette.paper)
                            .frame(width: 36, height: 30)
                            .background(Palette.crema)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                Divider().background(Palette.line)
                HStack {
                    Text("Grind").eyebrow(.caption)
                    Spacer()
                    TextField("e.g. 3.2", text: $draft.grindSetting)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                }
                HStack {
                    Text("Temp").eyebrow(.caption)
                    Spacer()
                    Stepper(value: $draft.tempC, in: 80...100, step: 1) {
                        Text(Formatters.temp(draft.tempC))
                            .font(.system(.body, weight: .semibold))
                            .tabularNumbers()
                            .foregroundStyle(Palette.ink)
                    }
                }
            }
        }
    }

    // MARK: Taste

    private var tasteSection: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Taste").eyebrow()
                TasteTagPicker(selection: $draft.tasteTags)
                Divider().background(Palette.line)
                ratingRow
                Divider().background(Palette.line)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Note").eyebrow(.caption2)
                    TextEditor(text: $draft.tasteNote)
                        .frame(minHeight: 64)
                        .font(.system(.subheadline))
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(Palette.ink)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10).stroke(Palette.line, lineWidth: 1)
                        )
                }
            }
        }
    }

    private var ratingRow: some View {
        HStack {
            Text("Rating").eyebrow(.caption)
            Spacer()
            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        HapticEngine.selection()
                        draft.rating = (draft.rating == star) ? nil : star
                    } label: {
                        Image(systemName: star <= (draft.rating ?? 0) ? EspressoIcon.star : "star")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(star <= (draft.rating ?? 0) ? Palette.crema : Palette.line)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Photo

    private var photoSection: some View {
        WarmCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Photo").eyebrow()
                if let data = draft.photoData, let uiImage = UIImage(data: data) {
                    HStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        Spacer()
                        Button(role: .destructive) {
                            draft.photoData = nil
                        } label: {
                            Text("Remove").font(.system(.subheadline, weight: .semibold))
                                .foregroundStyle(Palette.warn)
                        }
                    }
                } else {
                    PhotoPickerButton(data: $draft.photoData) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.roundedrectangle.angled")
                            Text("Add a photo")
                        }
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(Palette.espresso)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Palette.cream)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Palette.line, lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: Advanced

    private var advancedSection: some View {
        DisclosureGroup("Advanced", isExpanded: $draft.showsAdvanced) {
            VStack(spacing: 14) {
                stepperRow(label: "Pre-infusion", value: Binding(
                    get: { Double(draft.preInfusionSeconds ?? 0) },
                    set: { draft.preInfusionSeconds = $0 > 0 ? Int($0) : nil }
                ), range: 0...20, step: 1, suffix: "s")
                stepperRow(label: "Pressure", value: Binding(
                    get: { draft.pressureBar ?? 9.0 },
                    set: { draft.pressureBar = $0 }
                ), range: 0...12, step: 0.1, suffix: "bar")
            }
            .padding(.top, 12)
        }
        .font(.system(.subheadline, weight: .semibold))
        .foregroundStyle(Palette.ink)
        .padding(20)
        .background(Palette.paper)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.line, lineWidth: 1))
        .tint(Palette.crema)
    }

    private var goodPullToggle: some View {
        Toggle(isOn: $draft.isGoodPull) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Mark as a good pull")
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                Text("Pins to Today and seeds the diff card.")
                    .font(.system(.caption))
                    .foregroundStyle(Palette.inkSoft)
            }
        }
        .tint(Palette.good)
        .padding(20)
        .background(Palette.paper)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.line, lineWidth: 1))
    }

    // MARK: - Save

    private func save() {
        let shot = Shot(
            dose: draft.dose,
            yield: draft.yield,
            brewSeconds: draft.brewSeconds,
            grindSetting: draft.grindSetting,
            tempC: draft.tempC,
            preInfusionSeconds: draft.preInfusionSeconds,
            pressureBar: draft.pressureBar,
            tasteNote: draft.tasteNote.isEmpty ? nil : draft.tasteNote,
            rating: draft.rating,
            tasteTags: draft.tasteTags,
            photoData: draft.photoData,
            isGoodPull: draft.isGoodPull,
            bean: draft.bean,
            grinder: draft.grinder,
            machine: draft.machine,
            basket: draft.basket
        )
        context.insert(shot)
        try? context.save()
        HapticEngine.saveSuccess()
        onSaved(shot)
    }
}

#Preview {
    LogShotView()
        .modelContainer(for: [Shot.self, Bean.self, Grinder.self, Machine.self, Basket.self], inMemory: true)
}
