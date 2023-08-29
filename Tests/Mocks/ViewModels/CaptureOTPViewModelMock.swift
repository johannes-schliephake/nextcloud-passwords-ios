@testable import Passwords


final class CaptureOTPViewModelMock: ViewModelMock<CaptureOTPViewModel.State, CaptureOTPViewModel.Action>, CaptureOTPViewModelProtocol {
    
    convenience init(captureOtp: @escaping (OTP) -> Void) {
        self.init()
    }
    
}


extension CaptureOTPViewModel.State: Mock {
    
    convenience init() {
        self.init(isTorchAvailable: true, isTorchActive: false, showErrorAlert: false, didCaptureOtp: false)
    }
    
}
