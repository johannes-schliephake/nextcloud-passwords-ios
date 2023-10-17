import SwiftUI


protocol Pasteboard {
    
    func setObjects<T: _ObjectiveCBridgeable>(_ objects: [T], localOnly: Bool, expirationDate: Date?) where T._ObjectiveCType: NSItemProviderWriting
    
}


extension UIPasteboard: Pasteboard {}
