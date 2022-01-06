import SwiftUI


struct EditTagPageFallback: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var tipController: TipController
    
    @StateObject private var editTagController: EditTagController
    // @available(iOS 15, *) @FocusState private var focusedField: FocusField?
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
            .onChange(of: sessionController.state) {
                state in
                if state.isChallengeAvailable {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .apply {
                view in
                if #available(iOS 15, *) {
                    view
                        // .initialize(focus: $focusedField, with: editTagController.tag.id.isEmpty ? .tagLabel : nil)
                        .interactiveDismissDisabled(editTagController.hasChanges)
                }
                else {
                    view
                        .actionSheet(isPresented: $showCancelAlert) {
                            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_discardChanges")) {
                                presentationMode.wrappedValue.dismiss()
                            }])
                        }
                }
            }
    }
    
    private func listView() -> some View {
        List {
            tagLabelField()
            colorSelector()
            if editTagController.tag.id.isEmpty {
                favoriteButton()
            }
        }
        .listStyle(.insetGrouped)
        .apply {
            view in
            if #available(iOS 15, *) {
                view
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                // focusedField = nil
                            }
                            label: {
                                Text("_dismiss")
                                    .bold()
                            }
                        }
                    }
            }
        }
    }
    
    private func tagLabelField() -> some View {
        Section(header: Text("_name")) {
            TextField("-", text: $editTagController.tagLabel, onCommit: {
                applyAndDismiss()
            })
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            // .focused($focusedField, equals: .tagLabel)
                            .submitLabel(.done)
                    }
                }
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
                    ColorPicker("", selection: $editTagController.tagColor, supportsOpacity: false)
                        .labelsHidden()
                        .scaleEffect(200)
                    Rectangle()
                        .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                        .scaleEffect(10)
                        .allowsHitTesting(false)
                }
            )
        }
    }
    
    private func favoriteButton() -> some View {
        Button {
            editTagController.tagFavorite.toggle()
        }
        label: {
            Label("_favorite", systemImage: editTagController.tagFavorite ? "star.fill" : "star")
        }
    }
    
    @ViewBuilder private func cancelButton() -> some View {
        if #available(iOS 15.0, *) {
            Button("_cancel", role: .cancel) {
                cancelAndDismiss()
            }
            .actionSheet(isPresented: $showCancelAlert) {
                ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_discardChanges")) {
                    presentationMode.wrappedValue.dismiss()
                }])
            }
        }
        else {
            Button("_cancel") {
                cancelAndDismiss()
            }
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
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func applyAndDismiss() {
        guard editTagController.editIsValid,
              editTagController.tag.state?.isProcessing != true else {
            return
        }
        editTagController.applyToTag()
        presentationMode.wrappedValue.dismiss()
    }
    
}


extension EditTagPageFallback {
    
    enum FocusField: Hashable {
        case tagLabel
    }
    
}


struct EditTagPageFallbackPreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                EditTagPageFallback(entriesController: EntriesController.mock, tag: Tag.mock)
            }
            .showColumns(false)
        }
    }
    
}
