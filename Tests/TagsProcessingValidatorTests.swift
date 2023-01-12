import XCTest
@testable import Passwords
import Factory


final class TagsProcessingValidatorTests: XCTestCase {
    
    private let tagMocks = Container.tags()
    
    override func setUp() {
        super.setUp()
        
        Container.registerMocks()
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.Registrations.reset()
    }
    
    func testValidate_inputEmptyArray_returnsFalse() {
        let tagsProcessingValidator: any TagsProcessingValidating = TagsProcessingValidator()
        
        let result = tagsProcessingValidator.validate([])
        
        XCTAssertFalse(result)
    }
    
    func testValidate_inputNonProcessingTags_returnsFalse() {
        let tagsProcessingValidator: any TagsProcessingValidating = TagsProcessingValidator()
        
        let result = tagsProcessingValidator.validate(tagMocks)
        
        XCTAssertFalse(result)
    }
    
    func testValidate_inputOneProcessingTag_returnsTrue() {
        let tagsProcessingValidator: any TagsProcessingValidating = TagsProcessingValidator()
        
        tagMocks.randomElement()?.state = .updating
        let result = tagsProcessingValidator.validate(tagMocks)
        
        XCTAssertTrue(result)
    }
    
    func testValidate_inputOnlyProcessingTags_returnsTrue() {
        let tagsProcessingValidator: any TagsProcessingValidating = TagsProcessingValidator()
        
        tagMocks.forEach { $0.state = .updating }
        let result = tagsProcessingValidator.validate(tagMocks)
        
        XCTAssertTrue(result)
    }

}
