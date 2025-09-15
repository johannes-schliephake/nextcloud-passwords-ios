import SwiftUI


struct EditPasswordNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let password: Password
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EditPasswordPage(entriesController: entriesController, password: password)
        }
        .scrollDismissesKeyboard(.immediately)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
