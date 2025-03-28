import SwiftUI
import Combine
import Factory


protocol GlobalAlertsViewModelProtocol: ViewModel {
    
    init()
    
}


// TODO: tests
final class GlobalAlertsViewModel: GlobalAlertsViewModelProtocol {
    
    @Injected(\.purchaseService) private var purchaseService
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupPipelines()
    }
    
    private func setupPipelines() {
        purchaseService.transactionState
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { transactionState in
                switch transactionState {
                case .purchasing:
                    break
                case .pending:
                    UIAlertController.presentGlobalAlert(title: "_tipDeferred".localized, message: "_tipDeferredMessage".localized) { [weak self] in
                        self?.purchaseService.reset()
                    }
                case .purchased:
                    UIAlertController.presentGlobalAlert(title: "_tipReceived".localized, message: "_tipReceivedMessage".localized, dismissText: "_highFive".localized) { [weak self] in
                        self?.purchaseService.reset()
                    }
                case .failed:
                    UIAlertController.presentGlobalAlert(title: "_tipFailed".localized, message: "_tipFailedMessage".localized) { [weak self] in
                        self?.purchaseService.reset()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
}
