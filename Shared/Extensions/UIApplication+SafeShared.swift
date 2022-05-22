import SwiftUI


extension UIApplication {
    
    /// Make shared UIApplication available to main app even when sharing code with AutoFill credential provider and action extension
    static let safeShared: UIApplication? = {
        guard !UIApplication.isExtension,
              UIApplication.responds(to: NSSelectorFromString("sharedApplication")) else {
            return nil
        }
        return UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() as? UIApplication
    }()
    
}
