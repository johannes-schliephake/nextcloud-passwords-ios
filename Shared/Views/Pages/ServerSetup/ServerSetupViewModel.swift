import Foundation
import Combine
import Factory


protocol ServerSetupViewModelProtocol: ViewModel where State == ServerSetupViewModel.State, Action == ServerSetupViewModel.Action {
    
    init()
    
}


final class ServerSetupViewModel: ServerSetupViewModelProtocol {
    
    final class State: ObservableObject {
        
        @Published var serverAddress: String
        @Published fileprivate(set) var isServerAddressManaged: Bool
        @Published var showManagedServerAddressErrorAlert: Bool
        @Published fileprivate(set) var isValidating: Bool
        @Published fileprivate(set) var challengeAvailable: Bool
        @Published var focusedField: FocusField?
        
        let shouldDismiss = Signal()
        
        init(serverAddress: String, isServerAddressManaged: Bool, showManagedServerAddressErrorAlert: Bool, isValidating: Bool, challengeAvailable: Bool, focusedField: FocusField?) {
            self.serverAddress = serverAddress
            self.isServerAddressManaged = isServerAddressManaged
            self.showManagedServerAddressErrorAlert = showManagedServerAddressErrorAlert
            self.isValidating = isValidating
            self.challengeAvailable = challengeAvailable
            self.focusedField = focusedField
        }
        
    }
    
    enum Action {
        case connect
        case cancel
    }
    
    enum FocusField: Hashable {
        case serverAddress
    }
    
    static private let fallbackServerAddress = "https://"
    
    @Injected(\.loginUrlUseCase) private var loginUrlUseCase
    @Injected(\.initiateLoginUseCase) private var initiateLoginUseCase
    @Injected(\.managedConfigurationUseCase) private var managedConfigurationUseCase
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private var challenge: LoginFlowChallenge?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init(serverAddress: Self.fallbackServerAddress, isServerAddressManaged: false, showManagedServerAddressErrorAlert: false, isValidating: false, challengeAvailable: false, focusedField: .serverAddress)
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak let `self` = self
        
        managedConfigurationUseCase[\.$serverUrl]
            .sink { managedServerAddress in
                self?.state.serverAddress = managedServerAddress ?? Self.fallbackServerAddress
                self?.state.isServerAddressManaged = managedServerAddress != nil
            }
            .store(in: &cancellables)
        
        state.$serverAddress
            .dropFirst()
            .removeDuplicates()
            .handleEvents(receiveOutput: { _ in
                self?.initiateLoginUseCase(.cancel)
                self?.state.isValidating = false
                self?.challenge = nil
                self?.state.challengeAvailable = false
            })
            .handle(with: loginUrlUseCase, { .setString($0) }, publishing: \.$loginUrl)
            .handleEvents(receiveOutput: { url in
                self?.state.isValidating = url != nil
                self?.state.showManagedServerAddressErrorAlert = url == nil && self?.state.isServerAddressManaged == true
            })
            .debounce(for: 1.5, scheduler: \.userInitiatedScheduler)
            .compactMap { $0 }
            .compactFlatMapLatest { loginUrl -> AnyPublisher<LoginFlowChallenge?, Never>? in
                guard let initiateLoginUseCase = self?.initiateLoginUseCase else {
                    return nil
                }
                return Just(loginUrl)
                    .handle(with: initiateLoginUseCase, { .setLoginUrl($0) }, publishing: \.$challenge)
                    .optionalize()
                    .receive(on: \.mainScheduler)
                    .handleEvents(receiveFailure: { error in
                        self?.state.showManagedServerAddressErrorAlert = self?.state.isServerAddressManaged == true
                        self?.logger.log(error: error)
                    })
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .sink { challenge in
                self?.state.isValidating = false
                self?.challenge = challenge
                self?.state.challengeAvailable = challenge != nil
            }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .connect:
            guard let challenge else {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
        case .cancel:
            state.shouldDismiss()
        }
    }
    
}
