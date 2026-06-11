import SwiftUI
import FactoryKit


@main struct PasswordsApp: App {
    
    init() {
        _ = dependency(\.logger)
        _ = dependency(\.windowDataSource)
        _ = dependency(\.biometricAuthenticationController)
    }
    
    // MARK: Views
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onOpenURL { url in
                    guard let otp = OTP(from: url) else {
                        UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_extractOtpErrorMessage".localized)
                        return
                    }
                    dependency(\.autoFillController).receivedOtp = otp
                }
        }
    }
    
}
