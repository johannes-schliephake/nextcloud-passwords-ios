import XCTest
import Nimble
import Factory
@testable import Passwords


final class WindowSizeRepositoryTests: XCTestCase {
    
    @MockInjected(\.windowSizeDataSource) private var windowSizeDataSourceMock: WindowSizeDataSourceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testWindowSize_thenCallsWindowSizeDataSource() {
        let windowSizeRepository: any WindowSizeRepositoryProtocol = WindowSizeRepository()
        
        _ = windowSizeRepository.windowSize
        
        expect(self.windowSizeDataSourceMock).to(beAccessed(.once, on: "windowSize"))
    }
    
    func testWindowSize_whenWindowSizeDataSourceEmits_thenEmits() {
        let windowSizeRepository: any WindowSizeRepositoryProtocol = WindowSizeRepository()
        let windowSizeMock = CGSize(width: .random(in: 0...1000), height: .random(in: 0...1000))
        
        expect(windowSizeRepository.windowSize).to(emit(windowSizeMock, when: { self.windowSizeDataSourceMock._windowSize.send(windowSizeMock) }))
    }
    
}
