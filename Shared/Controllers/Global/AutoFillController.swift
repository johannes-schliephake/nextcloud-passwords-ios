import Foundation


final class AutoFillController: ObservableObject {
    
    static let `default` = AutoFillController()
    
    /// Attributes may be set by password credential extension
    @Published var complete: ((String, String) -> Void)?
    @Published var cancel: (() -> Void)?
    @Published var serviceURLs: [URL]?
    @Published var credentialIdentifier: String?
    var keychain: Crypto.CSEv1r1.Keychain?
    
}


extension AutoFillController: MockObject {
    
    static var mock: AutoFillController {
        AutoFillController()
    }
    
}
