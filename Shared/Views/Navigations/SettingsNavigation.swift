import SwiftUI
import Factory


struct SettingsNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            SettingsPage(viewModel: resolve(\.settingsViewModelType).init().eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
