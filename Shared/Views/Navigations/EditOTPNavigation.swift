import SwiftUI
import FactoryKit


struct EditOTPNavigation: View {
    
    let otp: OTP
    let updateOtp: (OTP?) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EditOTPPage(viewModel: dependency(\.editOTPViewModelType).init(otp: otp, updateOtp: updateOtp).eraseToAnyViewModel())
        }
        .apply { view in
            if #available(iOS 26, *) {
                view
                    .scrollEdgeEffectStyle(.soft, for: .top)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
