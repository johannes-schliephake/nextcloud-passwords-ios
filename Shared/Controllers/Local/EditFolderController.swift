import Foundation


final class EditFolderController: ObservableObject {
    
    let folder: Folder
    private let addFolder: () -> Void
    private let updateFolder: () -> Void
    
    @Published var folderLabel: String
    @Published var folderFavorite: Bool
    
    init(folder: Folder, addFolder: @escaping () -> Void, updateFolder: @escaping () -> Void) {
        self.folder = folder
        self.addFolder = addFolder
        self.updateFolder = updateFolder
        folderLabel = folder.label
        folderFavorite = folder.favorite
    }
    
    func applyToFolder() {
        if folder.id.isEmpty {
            folder.created = Date()
        }
        folder.edited = Date()
        folder.updated = Date()
        
        folder.label = folderLabel
        folder.favorite = folderFavorite
        
        if folder.id.isEmpty {
            addFolder()
        }
        else {
            updateFolder()
        }
    }
    
}
