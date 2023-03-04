import Factory
@testable import Passwords


extension Container {
    
    func registerMocks() {
        editFolderViewModelType.register { EditFolderViewModelMock.self }
        folderValidationService.register { FolderValidationServiceMock() }
        foldersService.register { FoldersServiceMock() }
        selectTagsViewModelType.register { SelectTagsViewModelMock.self }
        tagValidationService.register { TagValidationServiceMock() }
        tagsService.register { TagsServiceMock() }
        
        // TODO: remove
        entriesController.register { .mock }
    }
    
}
