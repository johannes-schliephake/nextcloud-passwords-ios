import Factory


extension Container {
    
    var editFolderViewModelType: Factory<any EditFolderViewModelProtocol.Type> {
        self { EditFolderViewModel.self }
    }
    var folderLabelValidator: Factory<any FolderLabelValidating> {
        self { FolderLabelValidator() }
            .singleton
    }
    var foldersService: Factory<any FoldersServiceProtocol> {
        self { FoldersService() }
            .singleton
    }
    var selectTagsViewModelType: Factory<any SelectTagsViewModelProtocol.Type> {
        self { SelectTagsViewModel.self }
    }
    var tagLabelValidator: Factory<any TagLabelValidating> {
        self { TagLabelValidator() }
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
