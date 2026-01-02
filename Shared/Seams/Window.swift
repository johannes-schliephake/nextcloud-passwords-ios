import SwiftUI
import Combine


protocol Window: AnyObject {
    
    var framePublisher: AnyPublisher<CGRect, Never> { get }
    
}


extension UIWindow: Window {
    
    var framePublisher: AnyPublisher<CGRect, Never> {
        publisher(for: \.frame)
            .eraseToAnyPublisher()
    }
    
}
