import XCTest
import Nimble
import Factory
@testable import Passwords


final class PasteboardServiceTests: XCTestCase {
    
    @MockInjected(\.pasteboardRepository) private var pasteboardRepositoryMock: PasteboardRepositoryMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testSet_thenCallsPasteboardRepository() {
        let pasteboardService: any PasteboardServiceProtocol = PasteboardService()
        let stringMock = String.random()
        let sensitiveMock = Bool.random()
        
        pasteboardService.set(string: stringMock, sensitive: sensitiveMock)
        
        expect(self.pasteboardRepositoryMock).to(beCalled(.once, on: "set(string:sensitive:)", withParameters: stringMock, sensitiveMock))
    }
    
}
