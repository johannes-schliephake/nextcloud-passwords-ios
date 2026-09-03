@testable import Passwords
import Foundation


final class WebAuthenticationSessionMock: WebAuthenticationSession, Mock, FunctionCallLogging, PropertyAccessLogging {

    var _window: any Window? // swiftlint:disable:this identifier_name
    var window: any Window? {
        get {
            logPropertyAccess()
            return _window
        }
        set {
            logPropertyAccess()
            _window = newValue
        }
    }
    
    var _initCompletionHandler: ((URL?, any Error?) -> Void)? // swiftlint:disable:this identifier_name
    init(url: URL, callbackURLScheme: String?, completionHandler: @escaping (URL?, any Error?) -> Void) {
        Self.logFunctionCall(parameters: self)
        logFunctionCall(parameters: url, callbackURLScheme)
        _initCompletionHandler = completionHandler
    }
    
    init() {}
    
    var _start = true // swiftlint:disable:this identifier_name
    func start() -> Bool {
        logFunctionCall()
        return _start
    }
    
    func cancel() {
        logFunctionCall()
    }
    
}


extension WebAuthenticationSessionMock: Equatable {
    
    static func == (lhs: WebAuthenticationSessionMock, rhs: WebAuthenticationSessionMock) -> Bool {
        lhs === rhs
    }
    
}
