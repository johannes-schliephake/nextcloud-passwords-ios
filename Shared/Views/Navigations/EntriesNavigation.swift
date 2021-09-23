import SwiftUI


struct EntriesNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    
    @StateObject private var entriesController = Configuration.isTestEnvironment ? EntriesController.mock : EntriesController()
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                EntriesPage(entriesController: entriesController)
            }
            else {
                EntriesPageFallback(entriesController: entriesController)
            }
        }
        .showColumns(sessionController.session != nil && !sessionController.state.isChallengeAvailable)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
