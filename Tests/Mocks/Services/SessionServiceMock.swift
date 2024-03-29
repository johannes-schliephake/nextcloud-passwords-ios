@testable import Passwords
import Combine


final class SessionServiceMock: SessionServiceProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let _username = PassthroughSubject<String?, Never>() // swiftlint:disable:this identifier_name
    var username: AnyPublisher<String?, Never> {
        logPropertyAccess()
        return _username.eraseToAnyPublisher()
    }
    
    let _server = PassthroughSubject<String?, Never>() // swiftlint:disable:this identifier_name
    var server: AnyPublisher<String?, Never> {
        logPropertyAccess()
        return _server.eraseToAnyPublisher()
    }
    
    var _isChallengePasswordStored = false // swiftlint:disable:this identifier_name
    var isChallengePasswordStored: Bool {
        logPropertyAccess()
        return _isChallengePasswordStored
    }
    
    func clearChallengePassword() {
        logFunctionCall()
    }
    
    func logout() {
        logFunctionCall()
    }
    
}
