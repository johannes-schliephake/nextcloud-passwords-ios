@testable import Passwords
import Combine


final class FoldersServiceMock: FoldersServiceProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let _folders = PassthroughSubject<[Folder], Never>() // swiftlint:disable:this identifier_name
    var folders: AnyPublisher<[Folder], Never> {
        logPropertyAccess()
        return _folders.eraseToAnyPublisher()
    }
    
    init() {}
    
    let _makeFolder = Folder(id: .random(), parent: .random()) // swiftlint:disable:this identifier_name
    func makeFolder(parentId: String) -> Folder {
        logFunctionCall(parameters: parentId)
        return _makeFolder
    }
    
    var _apply: Result<Void, FolderApplyError> = .success(()) // swiftlint:disable:this identifier_name
    func apply(to folder: Folder, folderLabel: String, folderFavorite: Bool, folderParent: String) throws {
        logFunctionCall(parameters: folder, folderLabel, folderFavorite, folderParent)
        try _apply.get()
    }
    
    func delete(folder: Folder) {
        logFunctionCall(parameters: folder)
    }
    
}
