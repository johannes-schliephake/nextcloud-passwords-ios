import SwiftUI
import Factory


@main struct PasswordsApp: App {
    
    @StateObject private var autoFillController = Configuration.isTestEnvironment ? AutoFillController.mock : AutoFillController.default
    
    init() {
        _ = resolve(\.logger)
        _ = resolve(\.windowSizeDataSource)
    }
    
    // MARK: Views
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(autoFillController)
                .onOpenURL { url in
                    guard let otp = OTP(from: url) else {
                        UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_extractOtpErrorMessage".localized)
                        return
                    }
                    autoFillController.receivedOtp = otp
                }
                .onAppear {
                    NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
                }
        }
    }
    
}
