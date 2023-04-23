import Factory


extension Container {
    
    var configurationType: Factory<any Configurating.Type> {
        self { Configuration.self }
    }
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
    var logger: Factory<any Logging> {
        self { Logger() }
            .cached
    }
    var logViewModelType: Factory<any LogViewModelProtocol.Type> {
        self { LogViewModel.self }
    }
    var pasteboardService: Factory<any PasteboardServiceProtocol> {
        self { PasteboardService() }
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
