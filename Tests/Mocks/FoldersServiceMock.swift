@testable import Passwords
import Combine


final class FoldersServiceMock: FoldersServiceProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    var propertyAccessLog = [String]()
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    let _folders = PassthroughSubject<[Folder], Never>() // swiftlint:disable:this identifier_name
    var folders: AnyPublisher<[Folder], Never> {
        logPropertyAccess()
        return _folders.eraseToAnyPublisher()
    }
    
    init() {}
    
    let _folderLabel = PassthroughSubject<String, Never>() // swiftlint:disable:this identifier_name
    func folderLabel(forId folderId: String?) -> AnyPublisher<String, Never> {
        logFunctionCall(parameters: [folderId as Any])
        return _folderLabel.eraseToAnyPublisher()
    }
    
    var _apply: Result <Void, FolderApplyError> = .success(()) // swiftlint:disable:this identifier_name
    func apply(to folder: Folder, folderLabel: String, folderFavorite: Bool, folderParent: String?) throws {
        logFunctionCall(parameters: [folder, folderLabel, folderFavorite, folderParent as Any])
        try _apply.get()
    }
    
    func delete(folder: Folder) {
        logFunctionCall(parameters: [folder])
    }
    
}
