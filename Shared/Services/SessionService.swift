import Combine
import Factory


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
        resolve(\.sessionController).$session
            .map(\.?.user)
            .eraseToAnyPublisher()
    }
    var server: AnyPublisher<String?, Never> {
        resolve(\.sessionController).$session
            .map(\.?.server)
            .eraseToAnyPublisher()
    }
    var isChallengePasswordStored: Bool {
        resolve(\.keychain).load(key: "challengePassword") != nil
    }
    
    func clearChallengePassword() {
        resolve(\.keychain).remove(key: "challengePassword")
    }
    
    func logout() {
        resolve(\.sessionController).logout()
    }
    
}
