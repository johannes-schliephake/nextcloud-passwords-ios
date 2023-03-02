import Foundation
import Combine
import Factory


protocol FoldersServiceProtocol {
    
    var folders: AnyPublisher<[Folder], Never> { get }
    
    func folderLabel(forId folderId: String?) -> AnyPublisher<String, Never>
    func validate(folderLabel: String, folderParent: String?) -> Bool
    func apply(to folder: Folder, folderLabel: String, folderFavorite: Bool, folderParent: String?) throws
    func delete(folder: Folder)
    
}


enum FolderApplyError: Error {
    case validationFailed
    case idNotAvailableLocally
}


// TODO: replace temporary implementation
final class FoldersService: FoldersServiceProtocol {
    
    @Injected(\.entriesController) private var entriesController
    @LazyInjected(\.folderLabelValidator) private var folderLabelValidator
    
    lazy private(set) var folders = entriesController.objectDidChangeRecently
        .prepend(())
        .compactMap { [weak self] in self?.entriesController.folders }
        .eraseToAnyPublisher()
    
    func folderLabel(forId folderId: String?) -> AnyPublisher<String, Never> {
        folders
            .map { $0.first { $0.id == folderId } }
            .map(\.?.label)
            .replaceNil(with: "_rootFolder".localized)
            .eraseToAnyPublisher()
    }
    
    func validate(folderLabel: String, folderParent: String?) -> Bool {
        folderLabelValidator.validate(folderLabel)
            && (folderParent == Entry.baseId || entriesController.folders?.contains { $0.id == folderParent } == true)
    }
    
    func apply(to folder: Folder, folderLabel: String, folderFavorite: Bool, folderParent: String?) throws {
        guard validate(folderLabel: folderLabel, folderParent: folderParent) else {
            throw FolderApplyError.validationFailed
        }
        guard folder.isIdLocallyAvailable else {
            throw FolderApplyError.idNotAvailableLocally
        }
        
        if folder.id.isEmpty {
            folder.created = Date()
        }
        folder.edited = Date()
        folder.updated = Date()
        
        folder.label = folderLabel
        folder.favorite = folderFavorite
        folder.parent = folderParent
        
        if folder.id.isEmpty {
            entriesController.add(folder: folder)
        } else {
            entriesController.update(folder: folder)
        }
    }
    
    func delete(folder: Folder) {
        entriesController.delete(folder: folder)
    }
    
}
