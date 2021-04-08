import Foundation


final class Session: ObservableObject {
    
    let server: String
    let user: String
    let password: String
    
    @Published private(set) var pendingRequestsAvailable = false
    @Published private(set) var invalidationReason: InvalidationReason?
    
    var sessionID: String?
    var keychain: Crypto.Keychain?
    
    private var pendingRequests = [() -> Void]() {
        didSet {
            if oldValue.isEmpty && !pendingRequests.isEmpty {
                pendingRequestsAvailable = true
            }
            else if !oldValue.isEmpty && pendingRequests.isEmpty {
                pendingRequestsAvailable = false
            }
        }
    }
    
    var isValid: Bool {
        invalidationReason == nil
    }
    
    init(server: String, user: String, password: String) {
        self.server = server
        self.user = user
        self.password = password
    }
    
    func append(pendingRequest: @escaping () -> Void) {
        DispatchQueue.main.async {
            [self] in
            pendingRequests.append(pendingRequest)
        }
    }
    
    func runPendingRequests() {
        pendingRequests.forEach { $0() }
        pendingRequests.removeAll()
    }
    
    func invalidate(reason: InvalidationReason) {
        DispatchQueue.main.async {
            [self] in
            invalidationReason = reason
        }
    }
    
}


extension Session {
    
    enum InvalidationReason {
        case logout
        case deauthorization
    }
    
}


extension Session: MockObject {
    
    static var mock: Session {
        Session(server: "https://example.com", user: "johannes.schliephake", password: "Qr47UtYI2Nau3ee3xP51ugl6FWbUwb7F97Yz")
    }
    
}
