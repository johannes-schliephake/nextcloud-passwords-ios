import SwiftUI


protocol WindowScene {
    
    associatedtype WindowType: Window
    
    var keyWindow: WindowType? { get }
    
}


extension UIWindowScene: WindowScene {}
