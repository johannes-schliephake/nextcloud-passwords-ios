import XCTest
import Nimble
import Factory
@testable import Passwords


final class WindowSizeServiceTests: XCTestCase {
    
    @MockInjected(\.windowSizeRepository) private var windowSizeRepositoryMock: WindowSizeRepositoryMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenWindowSizeIsNil() {
        let windowSizeService: any WindowSizeServiceProtocol = WindowSizeService()
        
        expect(windowSizeService.windowSize).to(beNil())
    }
    
    func testInit_thenCallsWindowSizeRepository() {
        _ = WindowSizeService()
        
        expect(self.windowSizeRepositoryMock).to(beAccessed(.once, on: "windowSize"))
    }
    
    func testInit_whenWindowSizeRepositoryEmits_thenSetsWindowSize() {
        let windowSizeService: any WindowSizeServiceProtocol = WindowSizeService()
        let windowSizeMock = CGSize(width: .random(in: 0...1000), height: .random(in: 0...1000))
        
        windowSizeRepositoryMock._windowSize.send(windowSizeMock)
        
        expect(windowSizeService.windowSize).to(equal(windowSizeMock))
    }
    
}
