import Foundation
import Combine
import Factory


protocol SettingsViewModelProtocol: ViewModel where State == SettingsViewModel.State, Action == SettingsViewModel.Action {
    
    init()
    
}


final class SettingsViewModel: SettingsViewModelProtocol {
    
    final class State: ObservableObject {
        
        @Published fileprivate(set) var username: String?
        @Published fileprivate(set) var server: String?
        fileprivate(set) var isChallengePasswordStored: Bool
        @Published fileprivate(set) var wasChallengePasswordCleared: Bool
        @Published var showLogoutAlert: Bool
        @Published fileprivate(set) var isOfflineStorageEnabled: Bool
        @Published fileprivate(set) var isAutomaticPasswordGenerationEnabled: Bool
        @Published fileprivate(set) var isUniversalClipboardEnabled: Bool
        @Published fileprivate(set) var canPurchaseTip: Bool
        @Published fileprivate(set) var tipProducts: [any Product]?
        @Published fileprivate(set) var isTipTransactionRunning: Bool
        let isTestFlight: Bool
        let betaUrl: URL?
        @Published fileprivate(set) var isLogAvailable: Bool
        let versionName: String
        let sourceCodeUrl: URL?
        
        let shouldDismiss = Signal()
        
        init(username: String?, server: String?, isChallengePasswordStored: Bool, wasChallengePasswordCleared: Bool, showLogoutAlert: Bool, isOfflineStorageEnabled: Bool, isAutomaticPasswordGenerationEnabled: Bool, isUniversalClipboardEnabled: Bool, canPurchaseTip: Bool, tipProducts: [any Product]?, isTipTransactionRunning: Bool, isTestFlight: Bool, betaUrl: URL?, isLogAvailable: Bool, versionName: String, sourceCodeUrl: URL?) {
            self.username = username
            self.server = server
            self.isChallengePasswordStored = isChallengePasswordStored
            self.wasChallengePasswordCleared = wasChallengePasswordCleared
            self.showLogoutAlert = showLogoutAlert
            self.isOfflineStorageEnabled = isOfflineStorageEnabled
            self.isAutomaticPasswordGenerationEnabled = isAutomaticPasswordGenerationEnabled
            self.isUniversalClipboardEnabled = isUniversalClipboardEnabled
            self.canPurchaseTip = canPurchaseTip
            self.tipProducts = tipProducts
            self.isTipTransactionRunning = isTipTransactionRunning
            self.isTestFlight = isTestFlight
            self.betaUrl = betaUrl
            self.isLogAvailable = isLogAvailable
            self.versionName = versionName
            self.sourceCodeUrl = sourceCodeUrl
        }
        
    }
    
    enum Action {
        case clearChallengePassword
        case logout
        case confirmLogout
        case setIsOfflineStorageEnabled(Bool)
        case setIsAutomaticPasswordGenerationEnabled(Bool)
        case setIsUniversalClipboardEnabled(Bool)
        case tip(any Product)
        case done
    }
    
    @Injected(\.sessionService) private var sessionService
    @Injected(\.settingsService) private var settingsService
    @Injected(\.purchaseService) private var purchaseService
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let isChallengePasswordStored = _sessionService.wrappedValue.isChallengePasswordStored
        let configuration = resolve(\.configurationType)
        let betaUrl = URL(string: "https://testflight.apple.com/join/iuljLJ4u")
        let versionName = "\(configuration.shortVersionString)\(configuration.isDebug || configuration.isTestFlight ? " (\(configuration.isDebug ? "Debug" : configuration.isTestFlight ? "TestFlight" : "Unknown"), Build \(configuration.buildNumberString))" : "")"
        let sourceCodeUrl = URL(string: "https://github.com/johannes-schliephake/nextcloud-passwords-ios")
        state = .init(username: nil, server: nil, isChallengePasswordStored: isChallengePasswordStored, wasChallengePasswordCleared: false, showLogoutAlert: false, isOfflineStorageEnabled: false, isAutomaticPasswordGenerationEnabled: false, isUniversalClipboardEnabled: false, canPurchaseTip: false, tipProducts: nil, isTipTransactionRunning: false, isTestFlight: configuration.isTestFlight, betaUrl: betaUrl, isLogAvailable: false, versionName: versionName, sourceCodeUrl: sourceCodeUrl)
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        sessionService.username
            .sink { self?.state.username = $0 }
            .store(in: &cancellables)
        
        sessionService.server
            .sink { self?.state.server = $0 }
            .store(in: &cancellables)
        
        settingsService.isOfflineStorageEnabledPublisher
            .sink { self?.state.isOfflineStorageEnabled = $0 }
            .store(in: &cancellables)
        
        settingsService.isAutomaticPasswordGenerationEnabledPublisher
            .sink { self?.state.isAutomaticPasswordGenerationEnabled = $0 }
            .store(in: &cancellables)
        
        settingsService.isUniversalClipboardEnabledPublisher
            .sink { self?.state.isUniversalClipboardEnabled = $0 }
            .store(in: &cancellables)
        
        purchaseService.products
            .receive(on: DispatchQueue.main)
            .sink { self?.state.tipProducts = $0 }
            .store(in: &cancellables)
        
        purchaseService.transactionState
            .receive(on: DispatchQueue.main)
            .sink { transactionState in
                if case .purchasing = transactionState {
                    self?.state.isTipTransactionRunning = true
                } else {
                    self?.state.isTipTransactionRunning = false
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            state.$tipProducts
                .map { $0?.isEmpty == false },
            state.$isTipTransactionRunning
                .map { !$0 }
        )
        .map { $0 && $1 }
        .sink { self?.state.canPurchaseTip = $0 }
        .store(in: &cancellables)
        
        logger.isAvailablePublisher
            .receive(on: DispatchQueue.main)
            .sink { self?.state.isLogAvailable = $0 }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .clearChallengePassword:
            sessionService.clearChallengePassword()
            state.wasChallengePasswordCleared = true
        case .logout:
            state.showLogoutAlert = true
        case .confirmLogout:
            sessionService.logout()
            state.shouldDismiss()
        case let .setIsOfflineStorageEnabled(isOfflineStorageEnabled):
            settingsService.isOfflineStorageEnabled = isOfflineStorageEnabled
        case let .setIsAutomaticPasswordGenerationEnabled(isAutomaticPasswordGenerationEnabled):
            settingsService.isAutomaticPasswordGenerationEnabled = isAutomaticPasswordGenerationEnabled
        case let .setIsUniversalClipboardEnabled(isUniversalClipboardEnabled):
            settingsService.isUniversalClipboardEnabled = isUniversalClipboardEnabled
        case let .tip(product):
            purchaseService.purchase(product: product)
        case .done:
            state.shouldDismiss()
        }
    }
    
}
