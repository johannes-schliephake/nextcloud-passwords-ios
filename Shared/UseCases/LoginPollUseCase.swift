import Combine
import Foundation
import FactoryKit


protocol LoginPollUseCaseProtocol: UseCase where Action == LoginPollUseCase.Action {}


// TODO: replace temporary implementation
final class LoginPollUseCase: LoginPollUseCaseProtocol {
    
    enum Action {
        case setPoll(LoginFlowChallenge.Poll)
    }
    
    private static let pollLifetime: TimeInterval = 20 * 60
    private static let pollInterval: TimeInterval = 2
    
    @LazyInjected(\.logger) private var logger
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setPoll(poll):
            var request = URLRequest(url: poll.endpoint)
            request.httpMethod = "POST"
            request.httpBody = Data("token=\(poll.token)".utf8)
            
            let sessionPublisher = dependency(\.urlSession).dataTaskPublisher(for: request)
                .tryMap { result in
                    guard let response = result.response as? HTTPURLResponse,
                          response.statusCode == 200 else {
                        throw URLError(.userAuthenticationRequired)
                    }
                    return result.data
                }
                .decode(type: Response.self, decoder: dependency(\.configurationType).jsonDecoder)
                .catch { error in
                    Fail(error: error)
                        .delay(for: .init(floatLiteral: Self.pollInterval), scheduler: DispatchQueue.global(qos: .utility))
                }
                .retry(.init(Self.pollLifetime / Self.pollInterval))
                .handleEvents(receiveFailure: { [weak self] error in
                    self?.logger.log(error: error)
                })
                .ignoreFailure()
                .map { Session(server: $0.server, user: $0.loginName, password: $0.appPassword) }
            
            dependency(\.sessionController).attachSessionPublisher(
                sessionPublisher
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            )
        }
    }
    
}


extension LoginPollUseCase {
    
    private struct Response: Decodable {
        
        let server: String
        let loginName: String
        let appPassword: String
        
    }
    
}
