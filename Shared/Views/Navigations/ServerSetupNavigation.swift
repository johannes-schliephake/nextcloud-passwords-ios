import SwiftUI


struct ServerSetupNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            ServerSetupPage()
        }
        .showColumns(false)
        .apply {
            view in
            if #available(iOS 16, *) {
                view
                    .scrollDismissesKeyboard(.interactively)
            }
        }
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
