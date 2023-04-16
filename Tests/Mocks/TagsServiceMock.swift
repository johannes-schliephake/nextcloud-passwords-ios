@testable import Passwords
import Foundation
import Combine


final class TagsServiceMock: TagsServiceProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let _tags = PassthroughSubject<[Tag], Never>() // swiftlint:disable:this identifier_name
    var tags: AnyPublisher<[Tag], Never> {
        logPropertyAccess()
        return _tags.eraseToAnyPublisher()
    }
    
    init() {}
    
    let _tagsForTagIds = PassthroughSubject<(valid: [Tag], invalid: [String]), Never>() // swiftlint:disable:this identifier_name
    func tags(for tagIds: [String]) -> AnyPublisher<(valid: [Tag], invalid: [String]), Never> {
        logFunctionCall(parameters: tagIds)
        return _tagsForTagIds.eraseToAnyPublisher()
    }
    
    var _addTag: Result <Tag, TagAddError> = .success(.init()) // swiftlint:disable:this identifier_name
    func addTag(label: String) throws -> Tag {
        logFunctionCall(parameters: label)
        return try _addTag.get()
    }
    
    var _allIdsLocallyAvailable = true  // swiftlint:disable:this identifier_name
    func allIdsLocallyAvailable(of tags: [Passwords.Tag]) -> Bool {
        logFunctionCall(parameters: tags)
        return _allIdsLocallyAvailable
    }
    
}
