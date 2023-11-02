@testable import Passwords
import Combine
import Foundation


final class WindowMock: Window, Mock, PropertyAccessLogging {
    
    let _framePublisher = PassthroughSubject<CGRect, Never>() // swiftlint:disable:this identifier_name
    var framePublisher: AnyPublisher<CGRect, Never> {
        logPropertyAccess()
        return _framePublisher.eraseToAnyPublisher()
    }
    
}
