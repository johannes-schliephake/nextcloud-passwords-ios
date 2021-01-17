import SwiftUI


extension UIApplication {
    
    static let isExtension = Bundle.main.bundlePath.hasSuffix(".appex")
    
}
