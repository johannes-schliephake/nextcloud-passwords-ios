@testable import Passwords
import Foundation


final class ShareOTPViewModelMock: ViewModelMock<ShareOTPViewModel.State, ShareOTPViewModel.Action>, ShareOTPViewModelProtocol {
    
    convenience init(otpUrl: URL) {
        self.init()
    }
    
}


extension ShareOTPViewModel.State: Mock {
    
    convenience init() {
        self.init(qrCode: .init(systemName: "qrcode"), qrCodeAvailable: true, showShareSheet: false)
    }
    
}
