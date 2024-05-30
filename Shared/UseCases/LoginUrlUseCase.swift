import Combine
import Foundation


protocol LoginUrlUseCaseProtocol: UseCase where State == LoginUrlUseCase.State, Action == LoginUrlUseCase.Action {}


final class LoginUrlUseCase: LoginUrlUseCaseProtocol {
    
    final class State {
        
        @Current(LoginURL?.self) fileprivate(set) var loginUrl
        
    }
    
    enum Action {
        case setString(String)
    }
    
    let state: State
    
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setString(string):
            state.loginUrl = .success(.init(string: string))
        }
    }
    
}
