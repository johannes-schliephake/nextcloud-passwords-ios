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


#if DEBUG

extension Container {
    
    static let password = Factory<Password>(scope: .shared) { .mock }
    static let passwords = Factory<[Password]>(scope: .shared) { Password.mocks }
    static let folder = Factory<Folder>(scope: .shared) { .mock }
    static let folders = Factory<[Folder]>(scope: .shared) { Folder.mocks }
    static let tag = Factory<Tag>(scope: .shared) { .mock }
    static let tags = Factory<[Tag]>(scope: .shared) { Tag.mocks }
    
    static func registerMocks() {
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

#endif
