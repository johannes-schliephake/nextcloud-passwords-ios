import SwiftUI
import Factory


@main struct PasswordsApp: App {
    
    init() {
        _ = resolve(\.logger)
        _ = resolve(\.windowSizeDataSource)
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
                    resolve(\.autoFillController).receivedOtp = otp
                }
                .onAppear {
                    NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
                }
        }
    }
    
}
