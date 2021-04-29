import SwiftUI


struct SettingsNavigation: View {
    
    let updateOfflineContainers: () -> Void
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SettingsPage(updateOfflineContainers: updateOfflineContainers)
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
