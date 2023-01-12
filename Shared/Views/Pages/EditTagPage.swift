import SwiftUI


struct EditTagPage: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var editTagController: EditTagController
    @FocusState private var focusedField: FocusField?
    @State private var showDeleteAlert = false
    @State private var showCancelAlert = false
    
    init(entriesController: EntriesController, tag: Tag) {
        _editTagController = StateObject(wrappedValue: EditTagController(entriesController: entriesController, tag: tag))
    }
    
    // MARK: Views
    
    var body: some View {
        listView()
            .navigationTitle("_tag")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton()
                }
            }
            .initialize(focus: $focusedField, with: editTagController.tag.id.isEmpty ? .tagLabel : nil)
            .interactiveDismissDisabled(editTagController.hasChanges)
    }
    
    private func listView() -> some View {
        List {
            tagLabelField()
            colorSelector()
            favoriteButton()
            if !editTagController.tag.id.isEmpty {
                deleteButton()
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    focusedField = nil
                }
                label: {
                    Text("_dismiss")
                        .bold()
                }
            }
        }
    }
    
    private func tagLabelField() -> some View {
        Section(header: Text("_name")) {
            TextField("-", text: $editTagController.tagLabel, onCommit: {
                applyAndDismiss()
            })
            .focused($focusedField, equals: .tagLabel)
            .submitLabel(.done)
        }
    }
    
    private func colorSelector() -> some View {
        Section(header: Text("_color")) {
            HStack {
                Label("_selectColor", systemImage: "paintpalette")
                    .foregroundColor(.accentColor)
                Spacer()
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color(white: 0.5, opacity: 0.35), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(editTagController.tagColor)
                    )
                    .frame(width: 20, height: 20)
            }
            .allowsHitTesting(false)
            .background(
                ZStack {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        /// `scaleEffect` and `ColorPicker` can't be combined on iPad to enlarge tap area because the color picker view isn't a sheet
                        LazyHStack(spacing: 0) {
                            ForEach(0..<50) {
                                _ in
                                ColorPicker("", selection: $editTagController.tagColor, supportsOpacity: false)
                                    .labelsHidden()
                            }
                        }
                    }
                    else {
                        ColorPicker("", selection: $editTagController.tagColor, supportsOpacity: false)
                            .labelsHidden()
                            .scaleEffect(100)
                    }
                    Rectangle()
                        .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                        .scaleEffect(10)
                        .allowsHitTesting(false)
                }
            )
        }
    }
    
    private func favoriteButton() -> some View {
        Section {
            Button {
                editTagController.tagFavorite.toggle()
            }
            label: {
                Label("_favorite", systemImage: editTagController.tagFavorite ? "star.fill" : "star")
            }
        }
    }
    
    private func deleteButton() -> some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        }
        label: {
            HStack {
                Spacer()
                Text("_deleteTag")
                Spacer()
            }
        }
        .actionSheet(isPresented: $showDeleteAlert) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deleteTag")) {
                deleteAndDismiss()
            }])
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel", role: .cancel) {
            cancelAndDismiss()
        }
        .actionSheet(isPresented: $showCancelAlert) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_discardChanges")) {
                dismiss()
            }])
        }
    }
    
    private func confirmButton() -> some View {
        Button(editTagController.tag.id.isEmpty ? "_create" : "_done") {
            applyAndDismiss()
        }
        .disabled(!editTagController.editIsValid)
    }
    
    // MARK: Functions
    
    private func cancelAndDismiss() {
        if editTagController.hasChanges {
            showCancelAlert = true
        }
        else {
            dismiss()
        }
    }
    
    private func applyAndDismiss() {
        guard editTagController.editIsValid,
              editTagController.tag.state?.isProcessing != true else {
            return
        }
        editTagController.applyToTag()
        dismiss()
    }
    
    private func deleteAndDismiss() {
        editTagController.clearTag()
        dismiss()
    }
    
}


extension EditTagPage {
    
    private enum FocusField: Hashable {
        case tagLabel
    }
    
}


#if DEBUG

struct EditTagPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                EditTagPage(entriesController: EntriesController.mock, tag: Tag.mock)
            }
            .showColumns(false)
        }
    }
    
}

#endif
