import SwiftUI
import Factory


struct SettingsNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SettingsPage(viewModel: resolve(\.settingsViewModelType).init().eraseToAnyViewModel())
        }
        .showColumns(false)
        .scrollDismissesKeyboard(.interactively)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
