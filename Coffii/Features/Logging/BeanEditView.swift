import SwiftUI
import SwiftData

/// Add or edit a Bean. `bean == nil` means create.
struct BeanEditView: View {
    let bean: Bean?
    var onCommit: (Bean) -> Void = { _ in }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var roaster = ""
    @State private var origin = ""
    @State private var process = ""
    @State private var roastLevel: RoastLevel? = .medium
    @State private var roastDate = Date()
    @State private var hasRoastDate = false
    @State private var notes = ""
    @State private var isFavorite = false

    private var isValid: Bool { !roaster.isEmpty || !origin.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Bean") {
                    TextField("Roaster", text: $roaster)
                    TextField("Origin", text: $origin)
                    TextField("Process (e.g. Washed)", text: $process)
                    Picker("Roast level", selection: $roastLevel) {
                        Text("—").tag(RoastLevel?.none)
                        ForEach(RoastLevel.allCases) { Text($0.label).tag(RoastLevel?.some($0)) }
                    }
                }
                Section("Roast date") {
                    Toggle("Known roast date", isOn: $hasRoastDate)
                    if hasRoastDate {
                        DatePicker("Roasted on", selection: $roastDate, displayedComponents: .date)
                    }
                }
                Section {
                    Toggle("Favorite", isOn: $isFavorite)
                    TextEditor(text: $notes).frame(minHeight: 80)
                } header: { Text("Notes") }
            }
            .navigationTitle(bean == nil ? "New bean" : "Edit bean")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { commit() }
                        .disabled(!isValid)
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    private func populateIfEditing() {
        guard let bean else { return }
        roaster = bean.roaster
        origin = bean.origin
        process = bean.process ?? ""
        roastLevel = bean.roastLevel
        if let date = bean.roastDate {
            roastDate = date
            hasRoastDate = true
        }
        notes = bean.notes
        isFavorite = bean.isFavorite
    }

    private func commit() {
        let target = bean ?? Bean()
        target.roaster = roaster.trimmingCharacters(in: .whitespaces)
        target.origin = origin.trimmingCharacters(in: .whitespaces)
        target.process = process.isEmpty ? nil : process
        target.roastLevel = roastLevel
        target.roastDate = hasRoastDate ? roastDate : nil
        target.notes = notes
        target.isFavorite = isFavorite
        if bean == nil { context.insert(target) }
        try? context.save()
        onCommit(target)
        dismiss()
    }
}
