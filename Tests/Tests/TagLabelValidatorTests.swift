import XCTest
import Factory
@testable import Passwords


final class TagLabelValidatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Container.registerMocks()
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.Registrations.reset()
    }
    
    func testValidate_inputRangeOfLengths_allowedLengthsReturnTrue() {
        let tagLabelValidator: any TagLabelValidating = TagLabelValidator()
        
        let testStrings = (0...100).map(String.random)
        let result = testStrings.map(tagLabelValidator.validate)
        
        let expected = [false] + .init(repeating: true, count: 48) + .init(repeating: false, count: 52)
        XCTAssertEqual(result, expected)
    }

}
