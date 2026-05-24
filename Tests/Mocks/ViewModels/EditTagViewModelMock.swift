@testable import Passwords
import FactoryKit


final class EditTagViewModelMock: ViewModelMock<EditTagViewModel.State, EditTagViewModel.Action>, EditTagViewModelProtocol {
    
    convenience init(tag: Tag) {
        self.init()
    }
    
}


extension EditTagViewModel.State: Mock {
    
    convenience init() {
        let tagMock = dependency(\.tag)
        self.init(tag: tagMock, isCreating: tagMock.id.isEmpty, tagLabel: tagMock.label, tagColor: .init(hex: tagMock.color)!, tagFavorite: tagMock.favorite, showDeletionConfirmation: false, showCancellationConfirmation: false, hasChanges: false, editIsValid: true, focusedField: nil)
    }
    
}
