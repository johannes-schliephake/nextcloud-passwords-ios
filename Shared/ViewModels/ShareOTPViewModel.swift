import Foundation
import Combine
import Factory
import UIKit.UIImage


protocol ShareOTPViewModelProtocol: ViewModel where State == ShareOTPViewModel.State, Action == ShareOTPViewModel.Action {
    
    init(otpUrl: URL)
    
}


final class ShareOTPViewModel: ShareOTPViewModelProtocol {
    
    final class State: ObservableObject {
        
        @Published fileprivate(set) var qrCode: UIImage?
        @Published fileprivate(set) var qrCodeAvailable: Bool
        @Published var showShareSheet: Bool
        
        init(qrCode: UIImage?, qrCodeAvailable: Bool, showShareSheet: Bool) {
            self.qrCode = qrCode
            self.qrCodeAvailable = qrCodeAvailable
            self.showShareSheet = showShareSheet
        }
        
    }
    
    enum Action {
        case share
    }
    
    @Injected(\.qrCodeService) private var qrCodeService
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private let otpUrl: URL
    private var cancellables = Set<AnyCancellable>()
    
    init(otpUrl: URL) {
        state = .init(qrCode: nil, qrCodeAvailable: false, showShareSheet: false)
        self.otpUrl = otpUrl
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        Just(otpUrl)
            .compactFlatMap { self?.qrCodeService.generateQrCode(from: $0) }
            .catch { error in
                self?.logger.log(error: error)
                return Empty<UIImage, Never>()
            }
            .receive(on: DispatchQueue.main)
            .sink { qrCode in
                self?.state.qrCode = qrCode
                self?.state.qrCodeAvailable = true
            }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .share:
            state.showShareSheet = true
        }
    }
    
}
