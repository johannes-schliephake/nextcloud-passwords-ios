import SwiftUI


struct AddOTPNavigation: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let otp: OTP
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EntriesPage(entriesController: entriesController)
        }
        .showColumns(false)
        .apply {
            view in
            if #available(iOS 16, *) {
                view
                    .scrollDismissesKeyboard(.interactively)
            }
        }
        .occlude(biometricAuthenticationController.hideContents)
        .onAppear {
            guard !Configuration.userDefaults.bool(forKey: "didAcceptAboutOtps") else {
                return
            }
            Configuration.userDefaults.set(true, forKey: "didAcceptAboutOtps")
            UIAlertController.presentGlobalAlert(title: "_aboutOtps".localized, message: "_aboutOtpsMessage".localized)
        }
        .environmentObject({
            let autoFillController = AutoFillController()
            autoFillController.mode = .app
            autoFillController.receivedOtp = otp
            autoFillController.hasField = true
            autoFillController.complete = { passwordId, _ in
                guard let password = entriesController.passwords?.first(where: { $0.id == passwordId }) else {
                    return
                }
                password.updated = .init()
                password.otp = otp
                entriesController.update(password: password)
                dismiss()
            }
            autoFillController.cancel = {
                dismiss()
            }
            return autoFillController
        }())
    }
    
}
