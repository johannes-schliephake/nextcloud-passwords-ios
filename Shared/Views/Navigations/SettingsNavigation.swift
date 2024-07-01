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
        .apply {
            view in
            if #available(iOS 16, *) {
                view
                    .scrollDismissesKeyboard(.interactively)
            }
        }
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
