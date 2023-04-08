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
    
    func add(tag: Tag) {
        logFunctionCall(parameters: tag)
    }
    
}
