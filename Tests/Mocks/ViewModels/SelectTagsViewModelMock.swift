@testable import Passwords
import Factory


final class SelectTagsViewModelMock: ViewModelMock<SelectTagsViewModel.State, SelectTagsViewModel.Action>, SelectTagsViewModelProtocol {
    
    convenience init(temporaryEntry: SelectTagsViewModel.TemporaryEntry, selectTags: @escaping ([Tag], [String]) -> Void) {
        self.init()
    }
    
}


extension SelectTagsViewModel.State: Mock {
    
    convenience init() {
        let passwordMock = resolve(\.password)
        self.init(temporaryEntry: .password(label: passwordMock.label, username: passwordMock.username, url: passwordMock.url, tags: passwordMock.tags), tagLabel: "", selectableTags: Tag.mocks.map { (tag: $0, isSelected: false) }, hasChanges: false, focusedField: nil)
    }
    
}
