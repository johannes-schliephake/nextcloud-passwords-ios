import Foundation


final class CredentialsController: ObservableObject {
    
    static let `default` = CredentialsController()
    
    @Published var credentials: Credentials? {
        didSet {
            guard let credentials = credentials else {
                keychain.remove(key: "server")
                keychain.remove(key: "user")
                keychain.remove(key: "password")
                return
            }
            keychain.store(key: "server", value: credentials.server)
            keychain.store(key: "user", value: credentials.user)
            keychain.store(key: "password", value: credentials.password)
        }
    }
    
    private let keychain = Keychain(service: Bundle.main.object(forInfoDictionaryKey: "AppService") as! String, accessGroup: Bundle.main.object(forInfoDictionaryKey: "AppKeychain") as! String)
    
    init() {
        guard let server = keychain.load(key: "server"),
              let user = keychain.load(key: "user"),
              let password = keychain.load(key: "password") else {
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
