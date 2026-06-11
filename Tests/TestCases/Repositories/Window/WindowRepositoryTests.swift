import XCTest
import Nimble
import FactoryKit
@testable import Passwords


final class WindowRepositoryTests: XCTestCase {
    
    @MockInjected(\.windowDataSource) private var windowDataSourceMock: WindowDataSourceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let windowRepository: any WindowRepositoryProtocol = WindowRepository()
        
        expect(windowRepository[\.window]).to(beNil())
    }
    
    func testInit_thenCallsWindowDataSource() {
        _ = WindowRepository()
        
        expect(self.windowDataSourceMock).to(beAccessed(.once, on: "$window"))
    }
    
    func testInit_whenWindowDataSourceEmittingWindow_thenSetsWindow() {
        let windowRepository: any WindowRepositoryProtocol = WindowRepository()
        let windowMock = WindowMock()
        
        windowDataSourceMock.mockState(\.window, value: .success(windowMock))
        
        expect(windowRepository[\.window]).to(be(windowMock))
    }
    
}
