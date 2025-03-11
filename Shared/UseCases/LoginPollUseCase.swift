import Combine
import Foundation
import Factory


protocol LoginPollUseCaseProtocol: UseCase where Action == LoginPollUseCase.Action {}


// TODO: replace temporary implementation
final class LoginPollUseCase: LoginPollUseCaseProtocol {
    
    enum Action {
        case setDataStore(any WebDataStore)
        case setPoll(LoginFlowChallenge.Poll)
        case startPolling
    }
    
    @LazyInjected(\.logger) private var logger
    
    private var dataStore: (any WebDataStore)?
    private var poll: LoginFlowChallenge.Poll?
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setDataStore(dataStore):
            self.dataStore = dataStore
        case let .setPoll(poll):
            self.poll = poll
        case .startPolling:
            guard let dataStore,
                  let poll else {
                logger.log(error: "UseCase usage inconsistency encountered, this case shouldn't be reachable")
                return
            }
            
            var request = URLRequest(url: poll.endpoint)
            request.httpMethod = "POST"
            request.httpBody = Data("token=\(poll.token)".utf8)
            
            let sessionPublisher = NetworkClient.default.dataTaskPublisher(for: request)
                .tryMap { result in
                    guard let response = result.response as? HTTPURLResponse,
                          response.statusCode == 200 else {
                        throw URLError(.userAuthenticationRequired)
                    }
                    return result.data
                }
                .decode(type: Response.self, decoder: resolve(\.configurationType).jsonDecoder)
                .catch { error in
                    Fail(error: error)
                        .delay(for: 1, scheduler: DispatchQueue.global(qos: .utility))
                }
                .retry(30)
                .handleEvents(receiveFailure: { [weak self] error in
                    self?.logger.log(error: error)
                })
                .ignoreFailure()
                .combineLatest(Future { promise in
                    DispatchQueue.main.async {
                        dataStore.httpCookieStore.getAllCookies { cookies in
                            let sessionCookie = cookies.first { $0.name == "nc_session_id" }
                            let sessionId = sessionCookie?.value
                            promise(.success(sessionId))
                        }
                    }
                })
                .map { response, temporarySessionId in
                    let appSession = Session(server: response.server, user: response.loginName, password: response.appPassword)
                    let webSession = temporarySessionId.map { Session(server: appSession.server, user: appSession.user, password: $0) }
                    return (appSession, webSession)
                }
                .flatMapLatest { appSession, webSession in
                    guard let webSession else {
                        return Just(appSession)
                            .eraseToAnyPublisher()
                    }
                    return DeleteAppPasswordOCSRequest(session: webSession).publisher
                        .handleEvents(receiveFailure: { [weak self] error in
                            self?.logger.log(error: error)
                        })
                        .replaceError(with: ())
                        .map { appSession }
                        .eraseToAnyPublisher()
                }
            
            SessionController.default.attachSessionPublisher(
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
