import SwiftUI


extension UIAlertController {
    
    static func presentGlobalAlert(title: String? = nil, message: String? = nil, dismiss: String? = nil, handler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: dismiss ?? "_dismiss".localized, style: .default, handler: {
            _ in
            handler?()
        }))
        
        /// Present alert with top view controller
        guard let shared = UIApplication.safeShared,
              var topViewController = shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController else {
            return
        }
        while let presentedViewController = topViewController.presentedViewController,
              !presentedViewController.isBeingDismissed {
            topViewController = presentedViewController
        }
        topViewController.present(alertController, animated: true)
    }
    
}
