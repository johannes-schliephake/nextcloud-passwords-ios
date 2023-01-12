import Factory


extension Container {
    
    static let selectTagsViewModelType = Factory<any SelectTagsViewModelProtocol.Type> { SelectTagsViewModel.self }
    static let tagLabelValidator = Factory<any TagLabelValidating>(scope: .singleton) { TagLabelValidator() }
    static let tagsProcessingValidator = Factory<any TagsProcessingValidating>(scope: .singleton) { TagsProcessingValidator() }
    static let tagsService = Factory<any TagsServiceProtocol>(scope: .singleton) { TagsService() }
    
    // TODO: remove
    static let entriesController = Factory(scope: .singleton) { EntriesController() }
    
}


#if DEBUG

extension Container {
    
    static let password = Factory<Password>(scope: .shared) { .mock }
    static let passwords = Factory<[Password]>(scope: .shared) { Password.mocks }
    static let tag = Factory<Tag>(scope: .shared) { .mock }
    static let tags = Factory<[Tag]>(scope: .shared) { Tag.mocks }
    
    static func registerMocks() {
        selectTagsViewModelType.register { SelectTagsViewModelMock.self }
        tagLabelValidator.register { TagLabelValidatorMock() }
        tagsProcessingValidator.register { TagsProcessingValidatorMock() }
        tagsService.register { TagsServiceMock() }
        
        // TODO: remove
        entriesController.register { .mock }
    }
    
}

#endif
