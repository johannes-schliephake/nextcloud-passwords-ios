@testable import Passwords
import Combine
import Foundation


final class NotificationsMock: Notifications, Mock, FunctionCallLogging {
    
    let _publisher = PassthroughSubject<Notification, Never>() // swiftlint:disable:this identifier_name
    func publisher(for name: Notification.Name, object: AnyObject?) -> AnyPublisher<Notification, Never> {
        logFunctionCall(parameters: name, String(describing: object))
        return _publisher.eraseToAnyPublisher()
    }
    
    func post(name: Notification.Name, object: Any?) {
        logFunctionCall(parameters: name, String(describing: object))
    }
    
}
