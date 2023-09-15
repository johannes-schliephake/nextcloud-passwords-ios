import Combine


protocol SessionServiceProtocol {
    
    var username: AnyPublisher<String?, Never> { get }
    var server: AnyPublisher<String?, Never> { get }
    
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
    func logout() {
        SessionController.default.logout()
    }
    
}
