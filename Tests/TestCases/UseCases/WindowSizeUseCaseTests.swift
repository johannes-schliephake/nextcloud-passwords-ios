import XCTest
import Nimble
import FactoryKit
@testable import Passwords


final class WindowSizeUseCaseTests: XCTestCase {
    
    @MockInjected(\.windowRepository) private var windowRepositoryMock: WindowRepositoryMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let windowSizeUseCase: any WindowSizeUseCaseProtocol = WindowSizeUseCase()
        
        expect(windowSizeUseCase[\.windowSize]).to(beNil())
    }
    
    func testInit_thenCallsWindowRepository() {
        _ = WindowSizeUseCase()

        expect(self.windowRepositoryMock).to(beAccessed(.once, on: "$window"))
    }
    
    func testInit_whenWindowRepositoryEmittingWindow_thenAccessesFramePublisher() {
        withExtendedLifetime(WindowSizeUseCase()) {
            let windowMock = WindowMock()
            windowRepositoryMock.mockState(\.window, value: .success(windowMock))
            
            expect(windowMock).to(beAccessed(.once, on: "framePublisher"))
        }
    }
    
    func testInit_whenFramePublisherEmitting_thenSetsWindowSize() {
        let windowSizeUseCase: any WindowSizeUseCaseProtocol = WindowSizeUseCase()
        let windowMock = WindowMock()
        windowRepositoryMock.mockState(\.window, value: .success(windowMock))
        let sizeMock = CGSize(width: .random(in: 0..<1000), height: .random(in: 0..<1000))
        
        windowMock._framePublisher.send(.init(origin: .init(x: .random(in: 0..<1000), y: .random(in: 0..<1000)), size: sizeMock))
        
        expect(windowSizeUseCase[\.windowSize]).to(equal(sizeMock))
    }
    
    func testInit_whenFramePublisherEmittingSameSizeMultipleTimes_thenSetsWindowSizeOnce() {
        let windowSizeUseCase: any WindowSizeUseCaseProtocol = WindowSizeUseCase()
        let windowMock = WindowMock()
        windowRepositoryMock.mockState(\.window, value: .success(windowMock))
        let sizeMock = CGSize(width: .random(in: 0..<1000), height: .random(in: 0..<1000))
        
        expect(windowSizeUseCase[\.$windowSize].dropFirst()).toNot(emit(when: {
            windowMock._framePublisher.send(.init(origin: .init(x: .random(in: 0..<1000), y: .random(in: 0..<1000)), size: sizeMock))
            windowMock._framePublisher.send(.init(origin: .init(x: .random(in: 0..<1000), y: .random(in: 0..<1000)), size: sizeMock))
            windowMock._framePublisher.send(.init(origin: .init(x: .random(in: 0..<1000), y: .random(in: 0..<1000)), size: sizeMock))
        }))
    }

}
