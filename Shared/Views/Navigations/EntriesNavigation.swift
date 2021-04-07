import SwiftUI


struct EntriesNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    
    @StateObject private var entriesController = Configuration.isTestEnvironment ? EntriesController.mock : EntriesController()
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EntriesPage(entriesController: entriesController)
        }
        .showColumns(sessionController.session != nil && !sessionController.challengeAvailable)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
