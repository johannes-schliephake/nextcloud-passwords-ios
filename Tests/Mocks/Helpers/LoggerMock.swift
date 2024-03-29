@testable import Passwords
import Combine


final class LoggerMock: Logging, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    var _events: [LogEvent]? // swiftlint:disable:this identifier_name
    var events: [LogEvent]? {
        logPropertyAccess()
        return _events
    }
    
    let _eventsPublisher = PassthroughSubject<[LogEvent]?, Never>() // swiftlint:disable:this identifier_name
    var eventsPublisher: AnyPublisher<[LogEvent]?, Never> {
        logPropertyAccess()
        return _eventsPublisher.eraseToAnyPublisher()
    }
    
    var _isAvailable = false // swiftlint:disable:this identifier_name
    var isAvailable: Bool {
        logPropertyAccess()
        return _isAvailable
    }
    
    let _isAvailablePublisher = PassthroughSubject<Bool, Never>() // swiftlint:disable:this identifier_name
    var isAvailablePublisher: AnyPublisher<Bool, Never> {
        logPropertyAccess()
        return _isAvailablePublisher.eraseToAnyPublisher()
    }
    
    func log(error: any Error, fileID: String, functionName: String, line: UInt) {
        logFunctionCall(parameters: String(describing: error), fileID, functionName, line)
    }
    
    func log(error: String, fileID: String, functionName: String, line: UInt) {
        logFunctionCall(parameters: error, fileID, functionName, line)
    }
    
    func log(info: String, fileID: String, functionName: String, line: UInt) {
        logFunctionCall(parameters: info, fileID, functionName, line)
    }
    
    func reset() {
        logFunctionCall()
    }
    
}
