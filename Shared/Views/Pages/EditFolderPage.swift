import SwiftUI


struct EditFolderPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var editFolderController: EditFolderController
    @FocusState private var focusedField: FocusField?
    @State private var showSelectFolderView = false
    @State private var showDeleteAlert = false
    @State private var showCancelAlert = false
    
    init(entriesController: EntriesController, folder: Folder, didAdd: ((Folder) -> Void)? = nil) {
        _editFolderController = StateObject(wrappedValue: EditFolderController(entriesController: entriesController, folder: folder, didAdd: didAdd))
    }
    
    // MARK: Views
    
    var body: some View {
        listView()
            .navigationTitle("_folder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton()
                }
            }
            .initialize(focus: $focusedField, with: editFolderController.folder.id.isEmpty ? .folderLabel : nil)
            .interactiveDismissDisabled(editFolderController.hasChanges)
    }
    
    private func listView() -> some View {
        List {
            folderLabelField()
            favoriteButton()
            moveSection()
            if !editFolderController.folder.id.isEmpty {
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
    
    private func folderLabelField() -> some View {
        Section(header: Text("_name")) {
            TextField("-", text: $editFolderController.folderLabel, onCommit: {
                applyAndDismiss()
            })
            .focused($focusedField, equals: .folderLabel)
            .submitLabel(.done)
        }
    }
    
    private func moveSection() -> some View {
        Section(header: Text("_folder")) {
            Button {
                showSelectFolderView = true
            }
            label: {
                Label(editFolderController.parentLabel, systemImage: "folder")
            }
            .sheet(isPresented: $showSelectFolderView) {
                SelectFolderNavigation(entriesController: editFolderController.entriesController, entry: .folder(editFolderController.folder), temporaryEntry: .folder(label: editFolderController.folderLabel, parent: editFolderController.folderParent), selectFolder: {
                    parent in
                    editFolderController.folderParent = parent.id
                })
            }
        }
    }
    
    private func favoriteButton() -> some View {
        Section {
            Button {
                editFolderController.folderFavorite.toggle()
            }
            label: {
                Label("_favorite", systemImage: editFolderController.folderFavorite ? "star.fill" : "star")
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
                Text("_deleteFolder")
                Spacer()
            }
        }
        .actionSheet(isPresented: $showDeleteAlert) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deleteFolder")) {
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
                presentationMode.wrappedValue.dismiss()
            }])
        }
    }
    
    private func confirmButton() -> some View {
        Button(editFolderController.folder.id.isEmpty ? "_create" : "_done") {
            applyAndDismiss()
        }
        .disabled(!editFolderController.editIsValid)
    }
    
    // MARK: Functions
    
    private func cancelAndDismiss() {
        if editFolderController.hasChanges {
            showCancelAlert = true
        }
        else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func applyAndDismiss() {
        guard editFolderController.editIsValid,
              editFolderController.folder.state?.isProcessing != true else {
            return
        }
        editFolderController.applyToFolder()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func deleteAndDismiss() {
        editFolderController.clearFolder()
        presentationMode.wrappedValue.dismiss()
    }
    
}


extension EditFolderPage {
    
    private enum FocusField: Hashable {
        case folderLabel
    }
    
}


struct EditFolderPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                EditFolderPage(entriesController: EntriesController.mock, folder: Folder.mocks.first!)
            }
            .showColumns(false)
        }
    }
    
}
