import Factory


extension Container {
    
    var editFolderViewModelType: Factory<any EditFolderViewModelProtocol.Type> {
        self { EditFolderViewModel.self }
    }
    var folderValidationService: Factory<any FolderValidationServiceProtocol> {
        self { FolderValidationService() }
            .cached
    }
    var foldersService: Factory<any FoldersServiceProtocol> {
        self { FoldersService() }
            .cached
    }
    var selectTagsViewModelType: Factory<any SelectTagsViewModelProtocol.Type> {
        self { SelectTagsViewModel.self }
    }
    var tagValidationService: Factory<any TagValidationServiceProtocol> {
        self { TagValidationService() }
            .cached
    }
    var tagsService: Factory<any TagsServiceProtocol> {
        self { TagsService() }
            .cached
    }
    
    // TODO: remove
    var entriesController: Factory<EntriesController> {
        self { .init() }
            .cached
    }
    
}
