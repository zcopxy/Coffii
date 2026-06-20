import SwiftUI
import SwiftData

/// Add or edit a Grinder. `grinder == nil` means create.
struct GrinderEditView: View {
    let grinder: Grinder?
    var onCommit: (Grinder) -> Void = { _ in }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var burrType = ""
    @State private var isStepless = false
    @State private var notes = ""

    private var isValid: Bool { !name.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Grinder") {
                    TextField("Name", text: $name)
                    TextField("Burr type (e.g. 64mm flat)", text: $burrType)
                    Toggle("Stepless", isOn: $isStepless)
                }
                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 80)
                }
            }
            .navigationTitle(grinder == nil ? "New grinder" : "Edit grinder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { commit() }.disabled(!isValid)
                }
            }
            .onAppear { if let grinder { name = grinder.name; burrType = grinder.burrType ?? ""; isStepless = grinder.isStepless; notes = grinder.notes } }
        }
    }

    private func commit() {
        let target = grinder ?? Grinder()
        target.name = name.trimmingCharacters(in: .whitespaces)
        target.burrType = burrType.isEmpty ? nil : burrType
        target.isStepless = isStepless
        target.notes = notes
        if grinder == nil { context.insert(target) }
        try? context.save()
        onCommit(target)
        dismiss()
    }
}

/// Add or edit a Machine. `machine == nil` means create.
struct MachineEditView: View {
    let machine: Machine?
    var onCommit: (Machine) -> Void = { _ in }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type = ""
    @State private var notes = ""

    private var isValid: Bool { !name.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Machine") {
                    TextField("Name", text: $name)
                    TextField("Type (e.g. Dual boiler)", text: $type)
                }
                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 80)
                }
            }
            .navigationTitle(machine == nil ? "New machine" : "Edit machine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { commit() }.disabled(!isValid)
                }
            }
            .onAppear { if let machine { name = machine.name; type = machine.type ?? ""; notes = machine.notes } }
        }
    }

    private func commit() {
        let target = machine ?? Machine()
        target.name = name.trimmingCharacters(in: .whitespaces)
        target.type = type.isEmpty ? nil : type
        target.notes = notes
        if machine == nil { context.insert(target) }
        try? context.save()
        onCommit(target)
        dismiss()
    }
}

/// Add or edit a Basket. `basket == nil` means create.
struct BasketEditView: View {
    let basket: Basket?
    var onCommit: (Basket) -> Void = { _ in }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var sizeGrams: Double = 18
    @State private var brand = ""
    @State private var isPressurized = false
    @State private var notes = ""

    private var isValid: Bool { !brand.isEmpty || sizeGrams > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basket") {
                    TextField("Brand", text: $brand)
                    Stepper(value: $sizeGrams, in: 10...30, step: 0.5) {
                        Text("Size: \(Formatters.grams(sizeGrams))").tabularNumbers()
                    }
                    Toggle("Pressurized", isOn: $isPressurized)
                }
                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 80)
                }
            }
            .navigationTitle(basket == nil ? "New basket" : "Edit basket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { commit() }.disabled(!isValid)
                }
            }
            .onAppear { if let basket { sizeGrams = basket.sizeGrams; brand = basket.brand; isPressurized = basket.isPressurized; notes = basket.notes } }
        }
    }

    private func commit() {
        let target = basket ?? Basket()
        target.brand = brand.trimmingCharacters(in: .whitespaces)
        target.sizeGrams = sizeGrams
        target.isPressurized = isPressurized
        target.notes = notes
        if basket == nil { context.insert(target) }
        try? context.save()
        onCommit(target)
        dismiss()
    }
}
