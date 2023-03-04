import Factory


extension Container {
    
    var editFolderViewModelType: Factory<any EditFolderViewModelProtocol.Type> {
        self { EditFolderViewModel.self }
    }
    var folderValidationService: Factory<any FolderValidationServiceProtocol> {
        self { FolderValidationService() }
            .singleton
    }
    var foldersService: Factory<any FoldersServiceProtocol> {
        self { FoldersService() }
            .singleton
    }
    var selectTagsViewModelType: Factory<any SelectTagsViewModelProtocol.Type> {
        self { SelectTagsViewModel.self }
    }
    var tagValidationService: Factory<any TagValidationServiceProtocol> {
        self { TagValidationService() }
            .singleton
    }
    var tagsService: Factory<any TagsServiceProtocol> {
        self { TagsService() }
            .singleton
    }
    
    // TODO: remove
    var entriesController: Factory<EntriesController> {
        self { .init() }
            .singleton
    }
    
}
