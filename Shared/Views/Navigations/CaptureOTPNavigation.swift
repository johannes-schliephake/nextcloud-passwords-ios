import SwiftUI


struct CaptureOTPNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let capture: (OTP) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            CaptureOTPPage(capture: capture)
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
