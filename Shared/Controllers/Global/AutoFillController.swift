import Foundation


final class AutoFillController: ObservableObject {
    
    static let `default` = AutoFillController()
    
    /// Attributes may be set by AutoFill credential provider or action extension
    @Published var mode: Mode = .app
    @Published var complete: ((String, String) -> Void)?
    @Published var cancel: (() -> Void)?
    @Published var serviceURLs: [URL]?
    @Published var credentialIdentifier: String?
    @Published var hasField = false
    var keychain: Crypto.CSEv1r1.Keychain?
    
    private init() {}
    
}


extension AutoFillController {
    
    enum Mode {
        case app
        case provider
        case `extension`
    }
    
}


extension AutoFillController: MockObject {
    
    static var mock: AutoFillController {
        AutoFillController()
    }
    
}
