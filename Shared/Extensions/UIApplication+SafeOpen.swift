import SwiftUI


extension UIApplication {
    
    /// Make UIApplication's open available to main app even when sharing code with a credential provider extension
    static let safeOpen: ((URL) -> Void)? = {
        guard let shared = safeShared,
              shared.responds(to: NSSelectorFromString("openURL:")) else {
            return nil
        }
        return {
            url in
            shared.perform(NSSelectorFromString("openURL:"), with: url)
        }
    }()
    
}
