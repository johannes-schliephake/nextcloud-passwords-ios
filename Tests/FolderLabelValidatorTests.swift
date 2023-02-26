import XCTest
import Factory
@testable import Passwords


final class FolderLabelValidatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Container.registerMocks()
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.Registrations.reset()
    }
    
    func testValidate_inputRangeOfLengths_allowedLengthsReturnTrue() {
        let folderLabelValidator: any FolderLabelValidating = FolderLabelValidator()
        
        let testStrings = (0...100).map(String.random)
        let result = testStrings.map(folderLabelValidator.validate)
        
        let expected = [false] + .init(repeating: true, count: 48) + .init(repeating: false, count: 52)
        XCTAssertEqual(result, expected)
    }

}
