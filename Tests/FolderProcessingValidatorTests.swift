import XCTest
@testable import Passwords
import Factory


final class FolderProcessingValidatorTests: XCTestCase {
    
    private let folderMock = Container.folder()
    
    override func setUp() {
        super.setUp()
        
        Container.registerMocks()
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.Registrations.reset()
    }
    
    func testValidate_inputNonProcessingFolder_returnsFalse() {
        let folderProcessingValidator: any FolderProcessingValidating = FolderProcessingValidator()
        
        let result = folderProcessingValidator.validate(folderMock)
        
        XCTAssertFalse(result)
    }
    
    func testValidate_inputProcessingFolder_returnsTrue() {
        let folderProcessingValidator: any FolderProcessingValidating = FolderProcessingValidator()
        
        folderMock.state = .updating
        let result = folderProcessingValidator.validate(folderMock)
        
        XCTAssertTrue(result)
    }

}
