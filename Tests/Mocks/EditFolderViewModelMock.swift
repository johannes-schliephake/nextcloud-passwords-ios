@testable import Passwords
import Factory


final class EditFolderViewModelMock: ViewModelMock<EditFolderViewModel.State, EditFolderViewModel.Action>, EditFolderViewModelProtocol {
    
    convenience init(folder: Folder, didEdit: ((Folder) -> Void)?) {
        self.init()
    }
    
}


extension EditFolderViewModel.State: Mock {
    
    convenience init() {
        let folderMock = Container.shared.folder()
        self.init(folder: folderMock, isCreating: folderMock.id.isEmpty, folderLabel: folderMock.label, folderFavorite: folderMock.favorite, folderParent: folderMock.parent, parentLabel: "_rootFolder".localized, showSelectFolderView: false, showDeleteAlert: false, showCancelAlert: false, hasChanges: false, editIsValid: true, focusedField: nil)
    }
    
}
