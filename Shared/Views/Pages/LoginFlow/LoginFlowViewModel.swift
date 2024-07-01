import Foundation
import Combine
import Factory


protocol LoginFlowViewModelProtocol: ViewModel where State == LoginFlowViewModel.State, Action == LoginFlowViewModel.Action {
    
    init(challenge: LoginFlowChallenge)
    
}


final class LoginFlowViewModel: LoginFlowViewModelProtocol {
    
    final class State: ObservableObject {
        
        @Published var request: URLRequest
        let userAgent: String
        let dataStore: any WebDataStore
        @Current(Bool.self) fileprivate(set) var isTrusted
        
        init(request: URLRequest, userAgent: String, dataStore: any WebDataStore) {
            self.request = request
            self.userAgent = userAgent
            self.dataStore = dataStore
        }
        
    }
    
    enum Action {
        case checkTrust(SecTrust)
    }
    
    @Injected(\.checkLoginGrantUseCase) private var checkLoginGrantUseCase
    @Injected(\.checkTrustUseCase) private var checkTrustUseCase
    @Injected(\.loginPollUseCase) private var loginPollUseCase
    
    let state: State
    
    private let trustSubject = PassthroughSubject<SecTrust, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(challenge: LoginFlowChallenge) {
        let configuration = resolve(\.configurationType)
        var request = URLRequest(url: challenge.login)
        if let language = configuration.preferredLanguage {
            request.addValue(language, forHTTPHeaderField: "Accept-Language")
        }
        let nonPersistentWebDataStore = resolve(\.nonPersistentWebDataStore)
        state = .init(request: request, userAgent: configuration.clientName, dataStore: nonPersistentWebDataStore)
        
        setupPipelines()
        
        loginPollUseCase(.setDataStore(nonPersistentWebDataStore))
        loginPollUseCase(.setPoll(challenge.poll))
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        state.$request
            .dropFirst()
            .compactMap(\.url)
            .handle(with: checkLoginGrantUseCase, { .setUrl($0) }, publishing: \.$granted)
            .filter { $0 }
            .ignoreValue()
            .sink { self?.loginPollUseCase(.startPolling) }
            .store(in: &cancellables)
        
        trustSubject
            .handle(with: checkTrustUseCase, { .setTrust($0) }, publishing: \.$isTrusted)
            .sink { [weak self] in self?.state.isTrusted = .success($0) }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .checkTrust(trust):
            trustSubject.send(trust)
        }
    }
    
}
