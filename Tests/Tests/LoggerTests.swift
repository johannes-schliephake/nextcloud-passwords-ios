import XCTest
import Nimble
import Factory
@testable import Passwords


final class LoggerTests: XCTestCase {
    
    private let expectedInitialEvent = LogEvent(type: .info, message: "Logging enabled", fileID: "Passwords/Logger.swift", functionName: "init()", line: 46)
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.manager.reset()
        ConfigurationMock.isDebug = true
        ConfigurationMock.isTestEnvironment = true
        ConfigurationMock.isTestFlight = false
    }
    
    func testInit_givenDebugConfiguration_thenEnablesLogging() {
        let logger: any Logging = Logger()
        
        expect(logger.isAvailable).to(beTrue())
        expect(logger.events).toNot(beNil())
    }
    
    func testInit_givenAppStoreConfiguration_thenDisablesLogging() {
        ConfigurationMock.isDebug = false
        ConfigurationMock.isTestEnvironment = false
        ConfigurationMock.isTestFlight = false
        
        let logger: any Logging = Logger()
        
        expect(logger.isAvailable).to(beFalse())
        expect(logger.events).to(beNil())
    }
    
    func testInit_thenLogsInitialInfo() throws {
        let logger: any Logging = Logger()
        
        expect(logger.events).to(haveCount(1))
        let event = try XCTUnwrap(logger.events?[0])
        expect(event).to(equal(expectedInitialEvent))
    }
    
    func testLog_givenError_thenEventIsAdded() throws {
        let logger: any Logging = Logger()
        let callLine: UInt = #line + 2
        
        logger.log(error: NCPasswordsRequestError.requestError)
        
        expect(logger.events).to(haveCount(2))
        let event = try XCTUnwrap(logger.events?[1])
        let expectedEvent = LogEvent(type: .error, message: "requestError", fileID: #fileID, functionName: #function, line: callLine)
        expect(event).to(equal(expectedEvent))
    }
    
    func testLog_givenError_thenEventsAreEmitted() throws {
        let logger: any Logging = Logger()
        let callLine: UInt = #line + 3
        
        let expectedEvent = LogEvent(type: .error, message: "requestError", fileID: #fileID, functionName: #function, line: callLine)
        expect(logger.eventsPublisher.dropFirst()).to(emit([expectedInitialEvent, expectedEvent], when: { logger.log(error: NCPasswordsRequestError.requestError) }))
    }
    
    func testLog_givenErrorString_thenEventIsAdded() throws {
        let logger: any Logging = Logger()
        let errorMessage = String.random()
        let callLine: UInt = #line + 2
        
        logger.log(error: errorMessage)
        
        expect(logger.events).to(haveCount(2))
        let event = try XCTUnwrap(logger.events?[1])
        let expectedEvent = LogEvent(type: .error, message: errorMessage, fileID: #fileID, functionName: #function, line: callLine)
        expect(event).to(equal(expectedEvent))
    }
    
    func testLog_givenErrorString_thenEventsAreEmitted() throws {
        let logger: any Logging = Logger()
        let errorMessage = String.random()
        let callLine: UInt = #line + 3
        
        let expectedEvent = LogEvent(type: .error, message: errorMessage, fileID: #fileID, functionName: #function, line: callLine)
        expect(logger.eventsPublisher.dropFirst()).to(emit([expectedInitialEvent, expectedEvent], when: { logger.log(error: errorMessage) }))
    }
    
    func testLog_givenInfo_thenEventIsAdded() throws {
        let logger: any Logging = Logger()
        let infoMessage = String.random()
        let callLine: UInt = #line + 2
        
        logger.log(info: infoMessage)
        
        expect(logger.events).to(haveCount(2))
        let event = try XCTUnwrap(logger.events?[1])
        let expectedEvent = LogEvent(type: .info, message: infoMessage, fileID: #fileID, functionName: #function, line: callLine)
        expect(event).to(equal(expectedEvent))
    }
    
    func testLog_givenInfo_thenEventsAreEmitted() throws {
        let logger: any Logging = Logger()
        let infoMessage = String.random()
        let callLine: UInt = #line + 3
        
        let expectedEvent = LogEvent(type: .info, message: infoMessage, fileID: #fileID, functionName: #function, line: callLine)
        expect(logger.eventsPublisher.dropFirst()).to(emit([expectedInitialEvent, expectedEvent], when: { logger.log(info: infoMessage) }))
    }
    
    func testReset_givenExistingEvents_thenClearsEventsAndLogsResetInfo() throws {
        let logger: any Logging = Logger()
        logger.log(error: NCPasswordsRequestError.requestError)
        logger.log(error: .random())
        logger.log(info: .random())
        
        logger.reset()
        
        expect(logger.events).to(haveCount(1))
        let event = try XCTUnwrap(logger.events?[0])
        let expectedEvent = LogEvent(type: .info, message: "Log cleared", fileID: "Passwords/Logger.swift", functionName: "reset()", line: 63)
        expect(event).to(equal(expectedEvent))
    }

}
