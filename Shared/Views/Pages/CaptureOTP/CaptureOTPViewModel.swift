import Foundation
import Combine
import Factory


protocol CaptureOTPViewModelProtocol: ViewModel where State == CaptureOTPViewModel.State, Action == CaptureOTPViewModel.Action {
    
    init(captureOtp: @escaping (OTP) -> Void)
    
}


final class CaptureOTPViewModel: CaptureOTPViewModelProtocol {
    
    final class State: ObservableObject {
        
        @Published fileprivate(set) var isTorchAvailable: Bool
        @Published fileprivate(set) var isTorchActive: Bool
        @Published var showErrorAlert: Bool
        @Published fileprivate(set) var didCaptureOtp: Bool
        
        let shouldDismiss = Signal()
        
        init(isTorchAvailable: Bool, isTorchActive: Bool, showErrorAlert: Bool, didCaptureOtp: Bool) {
            self.isTorchAvailable = isTorchAvailable
            self.isTorchActive = isTorchActive
            self.showErrorAlert = showErrorAlert
            self.didCaptureOtp = didCaptureOtp
        }
        
    }
    
    enum Action {
        case toggleTorch
        case captureQrResult(Result<String, any Error>)
        case cancel
    }
    
    @Injected(\.torchService) private var torchService
    @LazyInjected(\.otpService) private var otpService
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private let captureOtp: (OTP) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(captureOtp: @escaping (OTP) -> Void) {
        state = .init(isTorchAvailable: false, isTorchActive: false, showErrorAlert: false, didCaptureOtp: false)
        self.captureOtp = captureOtp
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        torchService.isTorchAvailable
            .receive(on: DispatchQueue.main)
            .sink { self?.state.isTorchAvailable = $0 }
            .store(in: &cancellables)
        
        torchService.isTorchActive
            .receive(on: DispatchQueue.main)
            .sink { self?.state.isTorchActive = $0 }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .toggleTorch:
            do {
                try torchService.toggleTorch()
            } catch {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
            }
        case let .captureQrResult(.success(value)):
            guard !state.didCaptureOtp,
                  let otp = otpService.makeOtp(urlString: value) else {
                return
            }
            state.didCaptureOtp = true
            captureOtp(otp)
            state.shouldDismiss()
        case .captureQrResult(.failure):
            state.showErrorAlert = true
        case .cancel:
            state.shouldDismiss()
        }
    }
    
}
