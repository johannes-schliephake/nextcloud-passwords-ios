@testable import Passwords
import Foundation


final class LoggerMock: Logging, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    var _events: [Passwords.LogEvent]? = nil // swiftlint:disable:this identifier_name
    var events: [Passwords.LogEvent]? {
        logPropertyAccess()
        return _events
    }
    
    func log(error: Error, fileID: String, functionName: String, line: UInt) {
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
