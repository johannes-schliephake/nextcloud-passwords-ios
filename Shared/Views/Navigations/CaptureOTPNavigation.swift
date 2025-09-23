import SwiftUI
import Factory


struct CaptureOTPNavigation: View {
    
    let capture: (OTP) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            CaptureOTPPage(viewModel: resolve(\.captureOTPViewModelType).init(captureOtp: capture).eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
