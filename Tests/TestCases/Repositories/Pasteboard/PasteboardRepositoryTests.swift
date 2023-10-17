import XCTest
import Nimble
import Factory
@testable import Passwords


final class PasteboardRepositoryTests: XCTestCase {
    
    @MockInjected(\.pasteboardDataSource) private var pasteboardDataSourceMock: PasteboardDataSourceMock
    @MockInjected(\.settingsService) private var settingsServiceMock: SettingsServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testSet_thenCallsSettingsService() {
        let pasteboardRepository: any PasteboardRepositoryProtocol = PasteboardRepository()
        
        pasteboardRepository.set(string: .random(), sensitive: .random())
        
        expect(self.settingsServiceMock).to(beAccessed(.once, on: "isUniversalClipboardEnabled"))
    }
    
    func testSet_givenIsUniversalClipboardEnabledIsFalse_thenCallsPasteboardDataSource() {
        let pasteboardRepository: any PasteboardRepositoryProtocol = PasteboardRepository()
        settingsServiceMock._isUniversalClipboardEnabled = false
        let stringMock = String.random()
        let sensitiveMock = Bool.random()
        
        pasteboardRepository.set(string: stringMock, sensitive: sensitiveMock)
        
        expect(self.pasteboardDataSourceMock).to(beCalled(.once, on: "set(string:localOnly:sensitive:)", withParameters: stringMock, true, sensitiveMock))
    }
    
    func testSet_givenIsUniversalClipboardEnabledIsTrue_thenCallsPasteboardDataSource() {
        let pasteboardRepository: any PasteboardRepositoryProtocol = PasteboardRepository()
        settingsServiceMock._isUniversalClipboardEnabled = true
        let stringMock = String.random()
        let sensitiveMock = Bool.random()
        
        pasteboardRepository.set(string: stringMock, sensitive: sensitiveMock)
        
        expect(self.pasteboardDataSourceMock).to(beCalled(.once, on: "set(string:localOnly:sensitive:)", withParameters: stringMock, false, sensitiveMock))
    }
    
}
