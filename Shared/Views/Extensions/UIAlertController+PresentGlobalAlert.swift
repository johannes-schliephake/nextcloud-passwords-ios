import SwiftUI
import FactoryKit


extension UIAlertController {
    
    static func presentGlobalAlert(title: String? = nil, message: String? = nil, dismissText: String? = nil, dismissHandler: (() -> Void)? = nil, confirmText: String? = nil, confirmHandler: (() -> Void)? = nil, destructive: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: dismissText ?? "_dismiss".localized, style: .default, handler: {
            _ in
            dismissHandler?()
        }))
        if let confirmText {
            alertController.addAction(UIAlertAction(title: confirmText, style: destructive ? .destructive : .default, handler: {
                _ in
                confirmHandler?()
            }))
        }
        
        /// Present alert on topmost view controller
        guard var rootViewController = dependency(\.rootViewController) else {
            return
        }
        while let presentedViewController = rootViewController.presentedViewController,
              !presentedViewController.isBeingDismissed {
            rootViewController = presentedViewController
        }
        rootViewController.present(alertController, animated: true)
    }
    
}
