import Foundation


final class EditFolderController: ObservableObject {
    
    let entriesController: EntriesController
    let folder: Folder
    let didAdd: ((Folder) -> Void)?
    
    @Published var folderLabel: String
    @Published var folderFavorite: Bool
    @Published var folderParent: String?
    
    init(entriesController: EntriesController, folder: Folder, didAdd: ((Folder) -> Void)?) {
        self.entriesController = entriesController
        self.folder = folder
        self.didAdd = didAdd
        folderLabel = folder.label
        folderFavorite = folder.favorite
        folderParent = folder.parent
    }
    
    var parentLabel: String {
        entriesController.folders?.first(where: { $0.id == folderParent })?.label ?? "_passwords".localized
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
        folder.parent = entriesController.folders?.contains { $0.id == folderParent } == true ? folderParent : Entry.baseId
        
        if folder.id.isEmpty {
            entriesController.add(folder: folder)
            didAdd?(folder)
        }
        else {
            entriesController.update(folder: folder)
        }
    }
    
    func clearFolder() {
        entriesController.delete(folder: folder)
    }
    
}
