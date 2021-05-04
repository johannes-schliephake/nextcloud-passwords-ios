import SwiftUI


struct EditFolderPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var sessionController: SessionController
    
    @StateObject private var editFolderController: EditFolderController
    
    init(folder: Folder, addFolder: @escaping () -> Void, updateFolder: @escaping () -> Void) {
        _editFolderController = StateObject(wrappedValue: EditFolderController(folder: folder, addFolder: addFolder, updateFolder: updateFolder))
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
            .onChange(of: sessionController.state) {
                state in
                if state.isChallengeAvailable {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
    
    private func listView() -> some View {
        List {
            folderLabelField()
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func folderLabelField() -> some View {
        Section(header: Text("_name")) {
            TextField("-", text: $editFolderController.folderLabel, onCommit: {
                applyAndDismiss()
            })
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func confirmButton() -> some View {
        Button(editFolderController.folder.id.isEmpty ? "_create" : "_done") {
            applyAndDismiss()
        }
        .disabled(editFolderController.folderLabel.isEmpty)
    }
    
    // MARK: Functions
    
    private func applyAndDismiss() {
        if !editFolderController.folderLabel.isEmpty {
            editFolderController.applyToFolder()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
}


struct EditFolderPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                EditFolderPage(folder: Folder.mock, addFolder: {}, updateFolder: {})
            }
            .showColumns(false)
        }
    }
    
}
