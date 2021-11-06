import Foundation


final class EditFolderController: ObservableObject {
    
    let folder: Folder
    let folders: [Folder]
    private let addFolder: () -> Void
    private let updateFolder: () -> Void
    
    @Published var folderLabel: String
    @Published var folderFavorite: Bool
    @Published var folderParent: String?
    
    init(folder: Folder, folders: [Folder], addFolder: @escaping () -> Void, updateFolder: @escaping () -> Void) {
        self.folder = folder
        self.folders = folders
        self.addFolder = addFolder
        self.updateFolder = updateFolder
        folderLabel = folder.label
        folderFavorite = folder.favorite
        folderParent = folder.parent
    }
    
    var hasChanges: Bool {
        folderLabel != folder.label ||
        folderFavorite != folder.favorite ||
        folderParent != folder.parent
    }
    
    var editIsValid: Bool {
        1...48 ~= folderLabel.count
    }
    
    func applyToFolder() {
        if folder.id.isEmpty {
            folder.created = Date()
        }
        folder.edited = Date()
        folder.updated = Date()
        
        folder.label = folderLabel
        folder.favorite = folderFavorite
        folder.parent = folderParent
        
        if folder.id.isEmpty {
            addFolder()
        }
        else {
            updateFolder()
        }
    }
    
}
