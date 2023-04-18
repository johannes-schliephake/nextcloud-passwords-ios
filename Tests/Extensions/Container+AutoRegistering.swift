import Factory
@testable import Passwords


extension Container: AutoRegistering {
    
    public func autoRegister() {
        Self.shared.editFolderViewModelType.register { EditFolderViewModelMock.self }
        Self.shared.folderValidationService.register { FolderValidationServiceMock() }
        Self.shared.foldersService.register { FoldersServiceMock() }
        Self.shared.logger.register { LoggerMock() }
        Self.shared.selectTagsViewModelType.register { SelectTagsViewModelMock.self }
        Self.shared.tagValidationService.register { TagValidationServiceMock() }
        Self.shared.tagsService.register { TagsServiceMock() }
        
        // TODO: remove
        Self.shared.entriesController.register { .mock }
    }
    
}
