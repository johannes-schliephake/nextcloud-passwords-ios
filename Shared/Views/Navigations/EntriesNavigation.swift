import SwiftUI


struct EntriesNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    @StateObject private var entriesController = ProcessInfo.processInfo.environment["TEST"] == "true" ? EntriesController.mock : EntriesController()
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EntriesPage(entriesController: entriesController)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
