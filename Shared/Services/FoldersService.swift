import Foundation
import Combine
import Factory


protocol FoldersServiceProtocol {
    
    var folders: AnyPublisher<[Folder], Never> { get }
    
    func makeFolder(parentId: String) -> Folder
    func apply(to folder: Folder, folderLabel: String, folderFavorite: Bool, folderParent: String) throws
    func delete(folder: Folder)
    
}


enum FolderApplyError: Error {
    case validationFailed
    case isProcessing
}


// TODO: replace temporary implementation
final class FoldersService: FoldersServiceProtocol {
    
    @Injected(\.entriesController) private var entriesController
    @LazyInjected(\.folderValidationService) private var folderValidationService
    @LazyInjected(\.configurationType) private var configurationType
    
    lazy private(set) var folders = entriesController.objectDidChangeRecently
        .prepend(())
        .compactMap { [weak self] in self?.entriesController.folders }
        .eraseToAnyPublisher()
    
    func makeFolder(parentId: String) -> Folder {
        .init(parent: parentId, client: configurationType.clientName)
    }
    
    func apply(to folder: Folder, folderLabel: String, folderFavorite: Bool, folderParent: String) throws {
        guard folderValidationService.validate(label: folderLabel, parent: folderParent) else {
            throw FolderApplyError.validationFailed
        }
        guard folder.state?.isProcessing != true else {
            throw FolderApplyError.isProcessing
        }
        
        let currentDate = resolve(\.currentDate)
        if folder.id.isEmpty {
            folder.created = currentDate
        }
        folder.edited = currentDate
        folder.updated = currentDate
        
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
