import Combine
import FactoryKit
import Foundation


protocol AuthenticationUseCaseProtocol: UseCase where State == AuthenticationUseCase.State, Action == AuthenticationUseCase.Action {}


final class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    
    final class State {
        
        @Current(Bool.self) fileprivate(set) var latestAttemptFailed
        
    }
    
    enum Action {
        case setChallenge(LoginFlowChallenge)
    }
    
    @LazyInjected(\.loginPollUseCase) private var loginPollUseCase
    @LazyInjected(\.windowRepository) private var windowRepository
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private var webAuthenticationSession: any WebAuthenticationSession?
    
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
            @Injected(\.webAuthenticationSessionType) var webAuthenticationSessionType
            webAuthenticationSession = webAuthenticationSessionType.init(url: challenge.login, callbackURLScheme: nil) { [weak self] _, error in
                self?.state.latestAttemptFailed = .success(error != nil)
            }
            webAuthenticationSession?.window = windowRepository[\.window]
            if webAuthenticationSession?.start() != true {
                logger.log(error: "Unable to launch web authentication session")
            }
        }
    }
    
}
