import SwiftUI
import Combine
import Factory


protocol TagsServiceProtocol {
    
    var tags: AnyPublisher<[Tag], Never> { get }
    
    func tags(for tagIds: [String]) -> AnyPublisher<(valid: [Tag], invalid: [String]), Never>
    func addTag(label: String) throws -> Tag
    func apply(to tag: Tag, tagLabel: String, tagColor: Color, tagFavorite: Bool) throws
    func delete(tag: Tag)
    func allIdsLocallyAvailable(of tags: [Tag]) -> Bool
    
}


enum TagAddError: Error {
    case validationFailed
}


enum TagApplyError: Error {
    case validationFailed
    case idNotAvailableLocally
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
        
        let currentDate = resolve(\.currentDate)
        let tag = Tag(label: label, client: Configuration.clientName, edited: currentDate, created: currentDate, updated: currentDate)
        entriesController.add(tag: tag)
        return tag
    }
    
    func apply(to tag: Tag, tagLabel: String, tagColor: Color, tagFavorite: Bool) throws {
        guard tagValidationService.validate(label: tagLabel) else {
            throw TagAddError.validationFailed
        }
        guard tag.isIdLocallyAvailable else {
            throw FolderApplyError.idNotAvailableLocally
        }
        
        let currentDate = resolve(\.currentDate)
        if tag.id.isEmpty {
            tag.created = currentDate
        }
        tag.edited = currentDate
        tag.updated = currentDate
        
        tag.label = tagLabel
        tag.color = tagColor.hex
        tag.favorite = tagFavorite
        
        if tag.id.isEmpty {
            entriesController.add(tag: tag)
        } else {
            entriesController.update(tag: tag)
        }
    }
    
    func delete(tag: Tag) {
        entriesController.delete(tag: tag)
    }
    
    func allIdsLocallyAvailable(of tags: [Tag]) -> Bool {
        tags.allSatisfy(\.isIdLocallyAvailable)
    }
    
}
