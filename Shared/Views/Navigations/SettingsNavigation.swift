import SwiftUI


struct SettingsNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SettingsPage()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
