import Combine
import Foundation


protocol Notifications {
    
    func publisher(for: Notification.Name, object: AnyObject?) -> AnyPublisher<Notification, Never>
    func post(name: Notification.Name, object: Any?)
    
}


extension Notifications {
    
    func publisher(for name: Notification.Name) -> AnyPublisher<Notification, Never> {
        publisher(for: name, object: nil)
    }
    
}


extension NotificationCenter: Notifications {
    
    func publisher(for name: Notification.Name, object: AnyObject?) -> AnyPublisher<Notification, Never> {
        (publisher(for: name, object: object) as NotificationCenter.Publisher)
            .eraseToAnyPublisher()
    }
    
}
