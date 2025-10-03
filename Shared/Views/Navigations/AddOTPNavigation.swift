import SwiftUI


struct AddOTPNavigation: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let entriesController: EntriesController
    let otp: OTP
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EntriesPage(entriesController: entriesController)
        }
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            guard !Configuration.userDefaults.bool(forKey: "didAcceptAboutOtps") else {
                return
            }
            UIAlertController.presentGlobalAlert(
                title: "_aboutOtps".localized,
                message: "_aboutOtpsMessage".localized,
                dismissHandler: { dismiss() },
                confirmText: "_confirm".localized,
                confirmHandler: { Configuration.userDefaults.set(true, forKey: "didAcceptAboutOtps") }
            )
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
