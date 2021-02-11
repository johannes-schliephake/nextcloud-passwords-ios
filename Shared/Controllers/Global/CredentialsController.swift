import Foundation


final class CredentialsController: ObservableObject {
    
    static let `default` = CredentialsController()
    
    @Published var credentials: Credentials? {
        didSet {
            guard let credentials = credentials else {
                Keychain.default.remove(key: "server")
                Keychain.default.remove(key: "user")
                Keychain.default.remove(key: "password")
                return
            }
            Keychain.default.store(key: "server", value: credentials.server)
            Keychain.default.store(key: "user", value: credentials.user)
            Keychain.default.store(key: "password", value: credentials.password)
        }
    }
    
    private init() {
        guard let server = Keychain.default.load(key: "server"),
              let user = Keychain.default.load(key: "user"),
              let password = Keychain.default.load(key: "password") else {
            return
        }
        credentials = Credentials(server: server, user: user, password: password)
    }
    
    private init(credentials: Credentials) {
        self.credentials = credentials
    }
    
    func logout() {
        credentials = nil
    }
    
}


extension CredentialsController: MockObject {
    
    static var mock: CredentialsController {
        CredentialsController(credentials: Credentials.mock)
    }
    
}
