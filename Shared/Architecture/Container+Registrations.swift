import Factory


extension Container {
    
    static let editFolderViewModelType = Factory<any EditFolderViewModelProtocol.Type> { EditFolderViewModel.self }
    static let folderLabelValidator = Factory<any FolderLabelValidating>(scope: .singleton) { FolderLabelValidator() }
    static let foldersService = Factory<any FoldersServiceProtocol>(scope: .singleton) { FoldersService() }
    static let selectTagsViewModelType = Factory<any SelectTagsViewModelProtocol.Type> { SelectTagsViewModel.self }
    static let tagLabelValidator = Factory<any TagLabelValidating>(scope: .singleton) { TagLabelValidator() }
    static let tagsService = Factory<any TagsServiceProtocol>(scope: .singleton) { TagsService() }
    
    // TODO: remove
    static let entriesController = Factory(scope: .singleton) { EntriesController() }
    
}
