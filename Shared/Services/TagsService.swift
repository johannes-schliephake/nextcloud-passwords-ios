import Combine
import Factory


protocol TagsServiceProtocol {
    
    var tags: AnyPublisher<[Tag], Never> { get }
    
    func tags(for tagIds: [String]) -> AnyPublisher<(valid: [Tag], invalid: [String]), Never>
    func add(tag: Tag)
    
}


// TODO: replace temporary implementation
final class TagsService: TagsServiceProtocol {
    
    @Injected(\.entriesController) private var entriesController
    
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
