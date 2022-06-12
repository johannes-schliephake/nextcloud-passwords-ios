import SwiftUI


struct EditPasswordNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let password: Password
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditPasswordPage(entriesController: entriesController, password: password)
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
