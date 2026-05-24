import Combine
import FactoryKit


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
        dependency(\.sessionController).$session
            .map(\.?.user)
            .eraseToAnyPublisher()
    }
    var server: AnyPublisher<String?, Never> {
        dependency(\.sessionController).$session
            .map(\.?.server)
            .eraseToAnyPublisher()
    }
    var isChallengePasswordStored: Bool {
        dependency(\.keychain).load(key: "challengePassword") != nil
    }
    
    func clearChallengePassword() {
        dependency(\.keychain).remove(key: "challengePassword")
    }
    
    func logout() {
        dependency(\.sessionController).logout()
    }
    
}
