@testable import Passwords
import Combine
import Foundation


final class WindowSizeRepositoryMock: WindowSizeRepositoryProtocol, Mock, PropertyAccessLogging {
    
    let _windowSize = PassthroughSubject<CGSize, Never>() // swiftlint:disable:this identifier_name
    var windowSize: AnyPublisher<CGSize, Never> {
        logPropertyAccess()
        return _windowSize.eraseToAnyPublisher()
    }
    
}
