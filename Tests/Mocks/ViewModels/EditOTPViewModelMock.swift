@testable import Passwords
import Factory


final class EditOTPViewModelMock: ViewModelMock<EditOTPViewModel.State, EditOTPViewModel.Action>, EditOTPViewModelProtocol {
    
    convenience init(otp: OTP, updateOtp: @escaping (OTP?) -> Void) {
        self.init()
    }
    
}


extension EditOTPViewModel.State: Mock {
    
    convenience init() {
        let otpMock = resolve(\.otp)
        self.init(isCreating: otpMock.secret.isEmpty, otpType: otpMock.type, otpAlgorithm: otpMock.algorithm, otpSecret: otpMock.secret, otpDigits: otpMock.digits, otpCounter: otpMock.counter, otpPeriod: otpMock.period, showMore: true, sharingUrl: otpMock.url!, sharingAvailable: true, nextFieldFocusable: false, showDeletionConfirmation: false, showCancellationConfirmation: false, hasChanges: false, editIsValid: true, focusedField: nil)
    }
    
}
