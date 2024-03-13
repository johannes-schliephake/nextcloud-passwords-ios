import Combine


protocol SessionServiceProtocol {
    
    var username: AnyPublisher<String?, Never> { get }
    var server: AnyPublisher<String?, Never> { get }
    var isChallengePasswordStored: Bool { get }
    
    func clearChallengePassword()
    func logout()
    
}


// TODO: replace temporary implementation
struct SessionService: SessionServiceProtocol {
    
    var username: AnyPublisher<String?, Never> {
        SessionController.default.$session
            .map(\.?.user)
            .eraseToAnyPublisher()
    }
    var server: AnyPublisher<String?, Never> {
        SessionController.default.$session
            .map(\.?.server)
            .eraseToAnyPublisher()
    }
    var isChallengePasswordStored: Bool {
        Keychain.default.load(key: "challengePassword") != nil
    }
    
    func clearChallengePassword() {
        Keychain.default.remove(key: "challengePassword")
    }
    
    func logout() {
        SessionController.default.logout()
    }
    
}
