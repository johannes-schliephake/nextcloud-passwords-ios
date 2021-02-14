import SwiftUI


extension UIPasteboard {
    
    var privateString: String? {
        get {
            string
        }
        set {
            guard let newValue = newValue else {
                return
            }
            UIPasteboard.general.setItems([[UIPasteboard.typeAutomatic: newValue]], options: [.localOnly: true, .expirationDate: Date(timeIntervalSinceNow: 30)])
        }
    }
    
}
