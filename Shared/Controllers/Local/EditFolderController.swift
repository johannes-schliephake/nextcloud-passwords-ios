import Foundation


final class EditFolderController: ObservableObject {
    
    let folder: Folder
    private let addFolder: () -> Void
    private let updateFolder: () -> Void
    
    @Published var folderLabel: String
    
    init(folder: Folder, addFolder: @escaping () -> Void, updateFolder: @escaping () -> Void) {
        self.folder = folder
        self.addFolder = addFolder
        self.updateFolder = updateFolder
        folderLabel = folder.label
    }
    
    func applyToFolder() {
        if folder.id.isEmpty {
            folder.created = Date()
        }
        folder.edited = Date()
        folder.updated = Date()
        
        folder.label = folderLabel
        
        if folder.id.isEmpty {
            addFolder()
        }
        else {
            updateFolder()
        }
    }
    
}
