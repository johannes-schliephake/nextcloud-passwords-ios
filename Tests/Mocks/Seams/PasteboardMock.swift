@testable import Passwords
import Foundation


final class PasteboardMock: Pasteboard, Mock, FunctionCallLogging {
    
    func setObjects<T>(_ objects: [T], localOnly: Bool, expirationDate: Date?) where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderWriting {
        logFunctionCall(parameters: String(describing: objects), localOnly, expirationDate)
    }
    
}
