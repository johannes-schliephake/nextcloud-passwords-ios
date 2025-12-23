import Combine
import Factory
import Foundation


protocol AuthenticationUseCaseProtocol: UseCase where Action == AuthenticationUseCase.Action {}


final class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    
    enum Action {
        case setChallenge(LoginFlowChallenge)
    }
    
    @LazyInjected(\.loginPollUseCase) private var loginPollUseCase
    @LazyInjected(\.windowRepository) private var windowRepository
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private var webAuthenticationSession: (any WebAuthenticationSession)?
    
    init() {
        state = .init()
    }
    
    deinit {
        webAuthenticationSession?.cancel()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setChallenge(challenge):
            loginPollUseCase(.setPoll(challenge.poll))
            webAuthenticationSession?.cancel()
            webAuthenticationSession = resolve(\.webAuthenticationSessionType).init(url: challenge.login, callbackURLScheme: nil) { _, _ in }
            webAuthenticationSession?.window = windowRepository[\.window]
            if webAuthenticationSession?.start() != true {
                logger.log(error: "Unable to launch web authentication session")
            }
        }
    }
    
}
