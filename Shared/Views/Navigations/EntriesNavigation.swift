import SwiftUI
import Factory


struct EntriesNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
#if DEBUG
    @StateObject private var entriesController = Configuration.isTestEnvironment ? EntriesController.mock : resolve(\.entriesController)
#else
    @StateObject private var entriesController = resolve(\.entriesController)
#endif
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EntriesPage(entriesController: entriesController)
        }
        .apply { view in
            if UIDevice.current.userInterfaceIdiom == .pad {
                NavigationSplitView(
                    columnVisibility: .constant(.all),
                    sidebar: { view },
                    detail: {}
                )
                .navigationSplitViewStyle(.balanced)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
