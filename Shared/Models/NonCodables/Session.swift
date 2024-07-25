import Foundation


final class Session: ObservableObject {
    
    let server: String
    let user: String
    let password: String
    
    @Published private(set) var pendingRequestsAvailable = false
    @Published private(set) var pendingCompletionsAvailable = false
    @Published private(set) var invalidationReason: InvalidationReason?
    
    var sessionID: String?
    var keychain: Crypto.CSEv1r1.Keychain?
    
    private var pendingRequests = [(() -> Void, () -> Void)]() {
        didSet {
            if oldValue.isEmpty && !pendingRequests.isEmpty {
                pendingRequestsAvailable = true
            }
            else if !oldValue.isEmpty && pendingRequests.isEmpty {
                pendingRequestsAvailable = false
            }
        }
    }
    private var pendingCompletions = [() -> Void]() {
        didSet {
            if oldValue.isEmpty && !pendingCompletions.isEmpty {
                pendingCompletionsAvailable = true
            }
            else if !oldValue.isEmpty && pendingCompletions.isEmpty {
                pendingCompletionsAvailable = false
            }
        }
    }
    
    var isValid: Bool {
        invalidationReason == nil
    }
    
    var hasAppPassword: Bool {
        let humanReadableCharacters = "abcdefgijkmnopqrstwxyzABCDEFGHJKLMNPQRSTWXYZ23456789" /// Taken from https://github.com/nextcloud/server/blob/master/lib/public/Security/ISecureRandom.php
        let segmentRegex = "[\(humanReadableCharacters)]{5}"
        let appPasswordRegex = "^(\(segmentRegex)-){4}\(segmentRegex)$"
        return password.range(of: appPasswordRegex, options: .regularExpression) != nil
    }
    
    init(server: String, user: String, password: String) {
        self.server = server
        self.user = user
        self.password = password
    }
    
    func append(pendingRequest: @escaping () -> Void, failure: @escaping () -> Void) {
        DispatchQueue.main.async {
            [self] in
            pendingRequests.append((pendingRequest, failure))
        }
    }
    
    func append(pendingCompletion: @escaping () -> Void) {
        DispatchQueue.main.async {
            [self] in
            pendingCompletions.append(pendingCompletion)
        }
    }
    
    func runPendingRequests() {
        pendingRequests.forEach { $0.0() }
        pendingRequests.removeAll()
        runPendingCompletions()
    }
    
    func runPendingRequestFailures() {
        pendingRequests.forEach { $0.1() }
        pendingRequests.removeAll()
        runPendingCompletions()
    }
    
    func runPendingCompletions() {
        pendingCompletions.forEach { $0() }
        pendingCompletions.removeAll()
    }
    
    func invalidate(reason: InvalidationReason) {
        DispatchQueue.main.async {
            [self] in
            invalidationReason = reason
        }
    }
    
    func generateFileLink(for filePath: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "nextcloud"
        urlComponents.host = "open-file"
        urlComponents.queryItems = [
            URLQueryItem(name: "user", value: user),
            URLQueryItem(name: "link", value: server),
            URLQueryItem(name: "path", value: String(filePath.dropFirst(filePath.hasPrefix("/") ? 1 : 0)))
        ]
        return urlComponents.url
    }
    
}


extension Session {
    
    enum InvalidationReason {
        case logout
        case deauthorization
        case noConnection
    }
    
}


extension Session: MockObject {
    
    static var mock: Session {
        Session(server: "https://example.com", user: "johannes.schliephake", password: "Qr47UtYI2Nau3ee3xP51ugl6FWbUwb7F97Yz")
    }
    
}
