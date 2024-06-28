import Combine
import Foundation


protocol ExtractSessionIdUseCaseProtocol: UseCase where State == ExtractSessionIdUseCase.State, Action == ExtractSessionIdUseCase.Action {}


// TODO: tests
final class ExtractSessionIdUseCase: ExtractSessionIdUseCaseProtocol {
    
    final class State {
        
        @Current(String?.self) fileprivate(set) var sessionId
        
    }
    
    enum Action {
        case setDataStore(any WebDataStore)
    }
    
    let state: State
    
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setDataStore(dataStore):
            DispatchQueue.main.async { [weak self] in
                dataStore.httpCookieStore.getAllCookies { cookies in
                    let sessionCookie = cookies.first { $0.name == "nc_session_id" }
                    let sessionId = sessionCookie?.value
                    self?.state.sessionId = .success(sessionId)
                }
            }
        }
    }
    
}
