@testable import Passwords
import Factory


final class EditTagViewModelMock: ViewModelMock<EditTagViewModel.State, EditTagViewModel.Action>, EditTagViewModelProtocol {
    
    convenience init(tag: Tag) {
        self.init()
    }
    
}


extension EditTagViewModel.State: Mock {
    
    convenience init() {
        let tagMock = resolve(\.tag)
        self.init(tag: tagMock, isCreating: tagMock.id.isEmpty, tagLabel: tagMock.label, tagColor: .init(hex: tagMock.color)!, tagFavorite: tagMock.favorite, showDeleteAlert: false, showCancelAlert: false, hasChanges: false, editIsValid: true, focusedField: nil)
    }
    
}
