import SwiftUI
import Factory


struct EditOTPNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let otp: OTP
    let updateOtp: (OTP?) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditOTPPage(viewModel: resolve(\.editOTPViewModelType).init(otp: otp, updateOtp: updateOtp).eraseToAnyViewModel())
        }
        .showColumns(false)
        .scrollDismissesKeyboard(.interactively)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
