import SwiftUI


struct SettingsNavigation: View {
    
    let updateOfflineData: () -> Void
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SettingsPage(updateOfflineData: updateOfflineData)
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
