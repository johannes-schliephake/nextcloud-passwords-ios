import XCTest
import Nimble
import Factory
@testable import Passwords


final class FolderValidationServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Container.shared.registerMocks()
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.manager.reset()
    }
    
    func testValidate_givenStringsOfDifferentLengths_thenAllowedLengthsReturnTrue() {
        let folderValidationService: any FolderValidationServiceProtocol = FolderValidationService()
        let testStrings = (0...100).map(String.random)
        
        let result = testStrings.map { folderValidationService.validate(label: $0, parent: Entry.baseId) }
        
        let expectedResult = [false] + .init(repeating: true, count: 48) + .init(repeating: false, count: 52)
        expect(result).to(equal(expectedResult))
    }

}
