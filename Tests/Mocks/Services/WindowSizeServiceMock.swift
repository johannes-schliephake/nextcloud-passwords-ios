@testable import Passwords
import Foundation


final class WindowSizeServiceMock: WindowSizeServiceProtocol, Mock, PropertyAccessLogging {
    
    var _windowSize: CGSize? // swiftlint:disable:this identifier_name
    var windowSize: CGSize? {
        logPropertyAccess()
        return _windowSize
    }
    
}
