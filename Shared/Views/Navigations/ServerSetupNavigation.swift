import SwiftUI
import Factory


struct ServerSetupNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            ServerSetupPage(viewModel: resolve(\.serverSetupViewModelType).init().eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
