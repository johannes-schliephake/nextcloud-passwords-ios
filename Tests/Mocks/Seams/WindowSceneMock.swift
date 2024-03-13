@testable import Passwords


final class WindowSceneMock: WindowScene, Mock, PropertyAccessLogging {
    
    var _keyWindow: WindowMock? // swiftlint:disable:this identifier_name
    var keyWindow: WindowMock? {
        logPropertyAccess()
        return _keyWindow
    }
    
}
