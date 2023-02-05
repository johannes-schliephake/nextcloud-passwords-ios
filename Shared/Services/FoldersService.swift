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
    case remoteIdNotAvailable
}


// TODO: replace temporary implementation
final class FoldersService: FoldersServiceProtocol { // swiftlint:disable:this file_types_order
    
    @Injected(Container.entriesController) private var entriesController
    @LazyInjected(Container.folderLabelValidator) private var folderLabelValidator
    @LazyInjected(Container.folderProcessingValidator) private var folderProcessingValidator
    
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
            && entriesController.folders?.contains { $0.id == folderParent } == true
    }
    
    func apply(to folder: Folder, folderLabel: String, folderFavorite: Bool, folderParent: String?) throws {
        guard validate(folderLabel: folderLabel, folderParent: folderParent) else {
            throw FolderApplyError.validationFailed
        }
        guard !folderProcessingValidator.validate(folder) else {
            throw FolderApplyError.remoteIdNotAvailable
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


#if DEBUG

final class FoldersServiceMock: FoldersServiceProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    var propertyAccessLog = [String]()
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    let _folders = PassthroughSubject<[Folder], Never>() // swiftlint:disable:this identifier_name
    var folders: AnyPublisher<[Folder], Never> {
        logPropertyAccess()
        return _folders.eraseToAnyPublisher()
    }
    
    init() {}
    
    let _folderLabelForIdFolderId = PassthroughSubject<String, Never>() // swiftlint:disable:this identifier_name
    func folderLabel(forId folderId: String?) -> AnyPublisher<String, Never> {
        logFunctionCall(parameters: [folderId as Any])
        return _folderLabelForIdFolderId.eraseToAnyPublisher()
    }
    
    var _validateFolderLabel = false // swiftlint:disable:this identifier_name
    func validate(folderLabel: String, folderParent: String?) -> Bool {
        logFunctionCall(parameters: [folderLabel, folderParent as Any])
        return _validateFolderLabel
    }
    
    var _applyTo: Result <Void, FolderApplyError> = .success(()) // swiftlint:disable:this identifier_name
    func apply(to folder: Folder, folderLabel: String, folderFavorite: Bool, folderParent: String?) throws {
        logFunctionCall(parameters: [folder, folderLabel, folderFavorite, folderParent as Any])
        try _applyTo.get()
    }
    
    func delete(folder: Folder) {
        logFunctionCall(parameters: [folder])
    }
    
}

#endif
