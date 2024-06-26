import Combine
import Foundation


protocol CheckTrustUseCaseProtocol: UseCase where State == CheckTrustUseCase.State, Action == CheckTrustUseCase.Action {}


// TODO: replace temporary implementation
final class CheckTrustUseCase: CheckTrustUseCaseProtocol {
    
    final class State {
        
        @Current(Bool.self) fileprivate(set) var isTrusted
        
    }
    
    enum Action {
        case setTrust(SecTrust?)
    }
    
    let state: State
    
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setTrust(trust):
            cancellable = AuthenticationChallengeController.default.checkTrust(trust)
                .first()
                .sink { [weak self] in self?.state.isTrusted = .success($0) }
        }
    }
    
}
