import Foundation
import Combine
import Factory


protocol TagsServiceProtocol {
    
    var tags: AnyPublisher<[Tag], Never> { get }
    
    func tags(for tagIds: [String]) -> AnyPublisher<(valid: [Tag], invalid: [String]), Never>
    func addTag(label: String) throws -> Tag
    func allIdsLocallyAvailable(of tags: [Tag]) -> Bool
    
}


enum TagAddError: Error {
    case validationFailed
}


// TODO: replace temporary implementation
final class TagsService: TagsServiceProtocol {
    
    @Injected(\.entriesController) private var entriesController
    @LazyInjected(\.tagValidationService) private var tagValidationService
    
    lazy private(set) var tags = entriesController.objectDidChangeRecently
        .prepend(())
        .compactMap { [weak self] in self?.entriesController.tags }
        .eraseToAnyPublisher()
    
    func tags(for tagIds: [String]) -> AnyPublisher<(valid: [Tag], invalid: [String]), Never> {
        tags
            .compactMap { EntriesController.tags(for: tagIds, in: $0) }
            .eraseToAnyPublisher()
    }
    
    func addTag(label: String) throws -> Tag {
        guard tagValidationService.validate(label: label) else {
            throw TagAddError.validationFailed
        }
        
        let currentDate = Container.shared.currentDate()
        let tag = Tag(label: label, client: Configuration.clientName, edited: currentDate, created: currentDate, updated: currentDate)
        entriesController.add(tag: tag)
        return tag
    }
    
    func allIdsLocallyAvailable(of tags: [Tag]) -> Bool {
        tags.allSatisfy(\.isIdLocallyAvailable)
    }
    
}
