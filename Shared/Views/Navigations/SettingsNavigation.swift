import SwiftUI


struct SettingsNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SettingsPage()
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
