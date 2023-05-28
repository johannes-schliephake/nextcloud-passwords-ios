import Foundation
import Combine
import Factory


protocol FoldersServiceProtocol {
    
    var folders: AnyPublisher<[Folder], Never> { get }
    
    func folderLabel(forId folderId: String?) -> AnyPublisher<String, Never>
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
    @LazyInjected(\.folderValidationService) private var folderValidationService
    
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
    
    func apply(to folder: Folder, folderLabel: String, folderFavorite: Bool, folderParent: String?) throws {
        guard folderValidationService.validate(label: folderLabel, parent: folderParent) else {
            throw FolderApplyError.validationFailed
        }
        guard folder.isIdLocallyAvailable else {
            throw FolderApplyError.idNotAvailableLocally
        }
        
        let currentDate = Container.shared.currentDate()
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
