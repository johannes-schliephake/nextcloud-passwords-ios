import Combine
import Foundation
import Factory


protocol InitiateLoginUseCaseProtocol: UseCase where State == InitiateLoginUseCase.State, Action == InitiateLoginUseCase.Action {}


// TODO: replace temporary implementation
final class InitiateLoginUseCase: InitiateLoginUseCaseProtocol {
    
    final class State {
        
        @Published fileprivate(set) var challenge: Result<LoginFlowChallenge, any Error>?
        
    }
    
    enum Action {
        case setLoginUrl(LoginURL)
    }
    
    @LazyInjected(\.configurationType) private var configurationType
    
    let state: State
    
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setLoginUrl(loginUrl):
            AuthenticationChallengeController.default.clearAcceptedCertificateHash()
            
            var request = URLRequest(url: loginUrl.value)
            request.httpMethod = "POST"
            
            weak var `self` = self
            cancellable = NetworkClient.default.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: LoginFlowChallenge.self, decoder: configurationType.jsonDecoder)
                .sink { self?.state.challenge = .success($0) } receiveFailure: { self?.state.challenge = .failure($0) }
        }
    }
    
}
