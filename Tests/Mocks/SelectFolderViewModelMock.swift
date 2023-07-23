@testable import Passwords
import Factory


final class SelectFolderViewModelMock: ViewModelMock<SelectFolderViewModel.State, SelectFolderViewModel.Action>, SelectFolderViewModelProtocol {
    
    convenience init(entry: Entry, temporaryEntry: SelectFolderViewModel.TemporaryEntry, selectFolder: @escaping (Folder) -> Void) {
        self.init()
    }
    
}


extension SelectFolderViewModel.State: Mock {
    
    convenience init() {
        let folderMocks = resolve(\.folders).sortedByLabel()
        let passwordMock = resolve(\.password)
        let tree = Node(value: Folder()) {
            Node(value: folderMocks[0])
            Node(value: folderMocks[1])
            Node(value: folderMocks[2])
        }
        self.init(sheetItem: nil, temporaryEntry: .password(label: passwordMock.label, username: passwordMock.username, url: passwordMock.url, folder: passwordMock.folder), tree: tree, selection: tree.value, hasChanges: false, selectionIsValid: true)
    }
    
}
