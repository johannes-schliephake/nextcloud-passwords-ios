import SwiftUI


extension UIApplication {
    
    /// Make UIApplication's canOpenURL available to main app even when sharing code with a credential provider extension
    static let safeCanOpenURL: ((URL) -> Bool)? = {
        let canOpenUrlSelector = NSSelectorFromString("canOpenURL:")
        guard let shared = safeShared,
              shared.responds(to: canOpenUrlSelector) else {
            return nil
        }
        return {
            url in
            shared.perform(canOpenUrlSelector, with: url) != nil
        }
    }()
    
}
