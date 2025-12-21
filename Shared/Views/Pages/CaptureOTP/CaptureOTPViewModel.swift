import Foundation
import Combine
import Factory


protocol CaptureOTPViewModelProtocol: ViewModel where State == CaptureOTPViewModel.State, Action == CaptureOTPViewModel.Action {
    
    init(captureOtp: @escaping (OTP) -> Void)
    
}


final class CaptureOTPViewModel: CaptureOTPViewModelProtocol {
    
    final class State: ObservableObject {
        
        @Published var showErrorAlert: Bool
        @Published fileprivate(set) var didCaptureOtp: Bool
        
        let shouldDismiss = Signal()
        
        init(showErrorAlert: Bool, didCaptureOtp: Bool) {
            self.showErrorAlert = showErrorAlert
            self.didCaptureOtp = didCaptureOtp
        }
        
    }
    
    enum Action {
        case captureQrResult(Result<String, any Error>)
        case cancel
    }
    
    @LazyInjected(\.otpService) private var otpService
    
    let state: State
    
    private let captureOtp: (OTP) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(captureOtp: @escaping (OTP) -> Void) {
        state = .init(showErrorAlert: false, didCaptureOtp: false)
        self.captureOtp = captureOtp
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
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
