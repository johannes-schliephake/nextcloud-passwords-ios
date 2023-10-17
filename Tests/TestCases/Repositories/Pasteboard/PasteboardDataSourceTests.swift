import XCTest
import Nimble
import Factory
@testable import Passwords


final class PasteboardDataSourceTests: XCTestCase {
    
    @Injected(\.currentDate) private var currentDateMock
    
    @MockInjected(\.pasteboard) private var pasteboardMock: PasteboardMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testSet_givenSensitiveIsTrue_thenCallsPasteboard() {
        let pasteboardDataSource: any PasteboardDataSourceProtocol = PasteboardDataSource()
        let stringMock = String.random()
        let localOnlyMock = Bool.random()
        
        pasteboardDataSource.set(string: stringMock, localOnly: localOnlyMock, sensitive: true)
        
        expect(self.pasteboardMock).to(beCalled(.once, on: "setObjects(_:localOnly:expirationDate:)", withParameters: "[\"\(stringMock)\"]", localOnlyMock, currentDateMock.advanced(by: 60)))
    }
    
    func testSet_givenSensitiveIsFalse_thenCallsPasteboard() {
        let pasteboardDataSource: any PasteboardDataSourceProtocol = PasteboardDataSource()
        let stringMock = String.random()
        let localOnlyMock = Bool.random()
        
        pasteboardDataSource.set(string: stringMock, localOnly: localOnlyMock, sensitive: false)
        
        expect(self.pasteboardMock).to(beCalled(.once, on: "setObjects(_:localOnly:expirationDate:)", withParameters: "[\"\(stringMock)\"]", localOnlyMock, nil as Date?))
    }
    
}
