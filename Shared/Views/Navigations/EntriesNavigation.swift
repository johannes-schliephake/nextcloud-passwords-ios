import SwiftUI
import Factory


struct EntriesNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    
#if DEBUG
    @StateObject private var entriesController = Configuration.isTestEnvironment ? EntriesController.mock : resolve(\.entriesController)
#else
    @StateObject private var entriesController = resolve(\.entriesController)
#endif
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EntriesPage(entriesController: entriesController)
        }
        .showColumns(sessionController.session != nil && !sessionController.state.isChallengeAvailable)
        .apply {
            view in
            if #available(iOS 16, *) {
                view
                    .scrollDismissesKeyboard(.interactively)
            }
        }
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
