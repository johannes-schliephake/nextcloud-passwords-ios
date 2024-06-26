import Combine
import Foundation


protocol CheckLoginGrantUseCaseProtocol: UseCase where State == CheckLoginGrantUseCase.State, Action == CheckLoginGrantUseCase.Action {}


// TODO: tests
final class CheckLoginGrantUseCase: CheckLoginGrantUseCaseProtocol {
    
    final class State {
        
        @Current(Bool.self) fileprivate(set) var granted
        
    }
    
    enum Action {
        case setUrl(URL)
    }
    
    let state: State
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setUrl(url):
            let relativeReference = url.relativeReference
            let granted = relativeReference.hasSuffix("/login/v2/grant") || relativeReference.hasSuffix("/login/v2/apptoken")
            state.granted = .success(granted)
        }
    }
    
}
