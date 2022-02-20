import SwiftUI


struct EditOTPNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let otp: OTP
    let updateOtp: (OTP?) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                EditOTPPage(otp: otp, updateOtp: updateOtp)
            }
            else {
                EditOTPPageFallback(otp: otp, updateOtp: updateOtp)
            }
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
