import Combine
import Factory


protocol TagsServiceProtocol {
    
    var tags: AnyPublisher<[Tag], Never> { get }
    
    func tags(for tagIds: [String]) -> AnyPublisher<(valid: [Tag], invalid: [String]), Never>
    func add(tag: Tag)
    
}


// TODO: replace temporary implementation
final class TagsService: TagsServiceProtocol { // swiftlint:disable:this file_types_order
    
    @Injected(Container.entriesController) private var entriesController
    
    lazy private(set) var tags = entriesController.objectDidChangeRecently
        .prepend(())
        .compactMap { [weak self] in self?.entriesController.tags }
        .eraseToAnyPublisher()
    
    func tags(for tagIds: [String]) -> AnyPublisher<(valid: [Tag], invalid: [String]), Never> {
        tags
            .compactMap { EntriesController.tags(for: tagIds, in: $0) }
            .eraseToAnyPublisher()
    }
    
    func add(tag: Tag) {
        entriesController.add(tag: tag)
    }
    
}


#if DEBUG

final class TagsServiceMock: TagsServiceProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    var propertyAccessLog = [String]()
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    let _tags = PassthroughSubject<[Tag], Never>() // swiftlint:disable:this identifier_name
    var tags: AnyPublisher<[Tag], Never> {
        logPropertyAccess()
        return _tags.eraseToAnyPublisher()
    }
    
    init() {}
    
    let _tagsForTagIds = PassthroughSubject<(valid: [Tag], invalid: [String]), Never>() // swiftlint:disable:this identifier_name
    func tags(for tagIds: [String]) -> AnyPublisher<(valid: [Tag], invalid: [String]), Never> {
        logFunctionCall(parameters: [tagIds])
        return _tagsForTagIds.eraseToAnyPublisher()
    }
    
    func add(tag: Tag) {
        logFunctionCall(parameters: [tag])
    }
    
}

#endif
