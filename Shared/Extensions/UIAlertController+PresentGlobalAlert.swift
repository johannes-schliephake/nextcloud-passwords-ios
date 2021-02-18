import SwiftUI


extension UIAlertController {
    
    static func presentGlobalAlert(title: String? = nil, message: String? = nil, dismissText: String? = nil, dismissHandler: (() -> Void)? = nil, confirmText: String? = nil, confirmHandler: (() -> Void)? = nil, destructive: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: dismissText ?? "_dismiss".localized, style: .default, handler: {
            _ in
            dismissHandler?()
        }))
        if let confirmText = confirmText {
            alertController.addAction(UIAlertAction(title: confirmText, style: destructive ? .destructive : .default, handler: {
                _ in
                confirmHandler?()
            }))
        }
        
        /// Present alert with top view controller
        guard let shared = UIApplication.safeShared,
              var topViewController = shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        while let presentedViewController = topViewController.presentedViewController,
              !presentedViewController.isBeingDismissed {
            topViewController = presentedViewController
        }
        topViewController.present(alertController, animated: true)
    }
    
}
