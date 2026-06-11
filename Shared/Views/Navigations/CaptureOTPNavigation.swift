import SwiftUI
import FactoryKit


struct CaptureOTPNavigation: View {
    
    let capture: (OTP) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            CaptureOTPPage(viewModel: dependency(\.captureOTPViewModelType).init(captureOtp: capture).eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
