import SwiftUI


extension UIApplication {
    
    /// Make UIApplication's open available to main app even when sharing code with a credential provider extension
    static let safeOpen: ((URL) -> Void)? = {
        let openUrlSelector = NSSelectorFromString("openURL:")
        guard let shared = safeShared,
              shared.responds(to: openUrlSelector) else {
            return nil
        }
        return {
            url in
            shared.perform(openUrlSelector, with: url)
        }
    }()
    
}
