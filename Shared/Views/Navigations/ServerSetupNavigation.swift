import SwiftUI


struct ServerSetupNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            ServerSetupPage()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
