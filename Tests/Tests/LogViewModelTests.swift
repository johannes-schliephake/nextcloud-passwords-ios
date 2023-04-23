import XCTest
import Nimble
import Factory
@testable import Passwords
import Combine


final class LogViewModelTests: XCTestCase {
    
    @Injected(\.logEvents) private var logEventMocks
    
    @MockInjected(\.logger) private var loggerMock: LoggerMock
    @MockInjected(\.pasteboardService) private var pasteboardServiceMock: PasteboardServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.manager.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        
        expect(logViewModel[\.isAvailable]).to(beTrue())
        expect(logViewModel[\.events]).to(beEmpty())
    }
    
    func testInit_whenLoggerEmittingIsAvailable_thenSetsIsAvailable() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        let isAvailableMock = Bool.random()
        
        loggerMock._isAvailablePublisher.send(isAvailableMock)
        
        expect(logViewModel[\.isAvailable]).toEventually(equal(isAvailableMock))
    }
    
    func testInit_whenLoggerEmittingIsAvailableFromBackgroundThread_thenSetsIsAvailableFromMainThread() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        var cancellables = Set<AnyCancellable>()
        var receivedOnMainThread = false
        logViewModel[\.$isAvailable]
            .dropFirst()
            .sink { _ in receivedOnMainThread = Thread.isMainThread }
            .store(in: &cancellables)
        
        DispatchQueue.global().async(flags: .enforceQoS) {
            self.loggerMock._isAvailablePublisher.send(.random())
        }
        
        expect(receivedOnMainThread).toEventually(beTrue())
    }
    
    func testInit_whenLoggerEmittingNilEvents_thenSetsEvents() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        
        loggerMock._eventsPublisher.send(nil)
        
        expect(logViewModel[\.events]).toAlways(beEmpty(), until: .milliseconds(100))
    }
    
    func testInit_whenLoggerEmittingEmptyEvents_thenSetsEvents() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        
        loggerMock._eventsPublisher.send([])
        
        expect(logViewModel[\.events]).toAlways(beEmpty(), until: .milliseconds(100))
    }
    
    func testInit_whenLoggerEmittingEvents_thenSetsEventsReversed() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        
        loggerMock._eventsPublisher.send(logEventMocks)
        
        expect(logViewModel[\.events]).toEventually(equal(logEventMocks.reversed()))
    }
    
    func testInit_whenLoggerEmittingEventsFromBackgroundThread_thenSetsEventsFromMainThread() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        var cancellables = Set<AnyCancellable>()
        var receivedOnMainThread = false
        logViewModel[\.$events]
            .dropFirst()
            .sink { _ in receivedOnMainThread = Thread.isMainThread }
            .store(in: &cancellables)
        
        DispatchQueue.global().async(flags: .enforceQoS) {
            self.loggerMock._eventsPublisher.send([])
        }
        
        expect(receivedOnMainThread).toEventually(beTrue())
    }
    
    func testCallAsFunction_givenLoggerIsAvailable_whenCallingCopyLog_thenCallsPasteboardService() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        loggerMock._isAvailable = true
        loggerMock._events = logEventMocks
        let expectedPasteboardString = """
        ⚠️ I'm an error event
            [File Passwords/LogEvent.swift, Function mocks, Line 71]
            [\(logEventMocks[0].dateDescription)]
        ℹ️ I'm an info event
            [File Passwords/LogEvent.swift, Function mocks, Line 72]
            [\(logEventMocks[1].dateDescription)]
        """
        
        logViewModel(.copyLog)
        
        expect(self.pasteboardServiceMock).to(beCalled(.once, on: "set(_:)", withParameter: expectedPasteboardString))
    }
    
    func testCallAsFunction_givenLoggerIsUnavailable_whenCallingCopyLog_thenDoesntCallPasteboardService() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        loggerMock._isAvailable = false
        loggerMock._events = nil
        
        logViewModel(.copyLog)
        
        expect(self.pasteboardServiceMock).toNot(beCalled())
    }
    
    func testCallAsFunction_whenCallingCopyEvent_thenCallsPasteboardService() {
        let logViewModel: any LogViewModelProtocol = LogViewModel()
        let expectedPasteboardString = """
        ⚠️ I'm an error event
            [File Passwords/LogEvent.swift, Function mocks, Line 71]
            [\(logEventMocks[0].dateDescription)]
        """
        
        logViewModel(.copyEvent(logEventMocks[0]))
        
        expect(self.pasteboardServiceMock).to(beCalled(.once, on: "set(_:)", withParameter: expectedPasteboardString))
    }
    
}
