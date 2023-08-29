import SwiftUI


struct CaptureOTPNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let capture: (OTP) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            CaptureOTPPage(viewModel: CaptureOTPViewModel(captureOtp: capture).eraseToAnyViewModel())
        }
        .showColumns(false)
        .apply {
            view in
            if #available(iOS 16, *) {
                view
                    .scrollDismissesKeyboard(.interactively)
            }
        }
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
