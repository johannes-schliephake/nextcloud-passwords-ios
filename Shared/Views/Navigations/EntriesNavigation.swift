import SwiftUI


struct EntriesNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var credentialsController: CredentialsController
    
    @StateObject private var entriesController = Configuration.isTestEnvironment ? EntriesController.mock : EntriesController()
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EntriesPage(entriesController: entriesController)
        }
        .showColumns(credentialsController.credentials != nil)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
