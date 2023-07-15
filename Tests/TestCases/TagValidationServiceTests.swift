import XCTest
import Nimble
import Factory
@testable import Passwords


final class TagValidationServiceTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testValidate_givenStringsOfDifferentLengths_thenAllowedLengthsReturnTrue() {
        let tagValidationService: any TagValidationServiceProtocol = TagValidationService()
        let testStrings = (0...100).map(String.random)
        
        let result = testStrings.map(tagValidationService.validate)
        
        let expectedResult = [false] + .init(repeating: true, count: 48) + .init(repeating: false, count: 52)
        expect(result).to(equal(expectedResult))
    }

}
