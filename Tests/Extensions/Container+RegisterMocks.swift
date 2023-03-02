import Factory
@testable import Passwords


extension Container {
    
    func registerMocks() {
        editFolderViewModelType.register { EditFolderViewModelMock.self }
        folderLabelValidator.register { FolderLabelValidatorMock() }
        foldersService.register { FoldersServiceMock() }
        selectTagsViewModelType.register { SelectTagsViewModelMock.self }
        tagLabelValidator.register { TagLabelValidatorMock() }
        tagsService.register { TagsServiceMock() }
        
        // TODO: remove
        entriesController.register { .mock }
    }
    
}
