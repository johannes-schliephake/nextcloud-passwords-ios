import SwiftUI


struct EditPasswordNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let password: Password
    let addPassword: () -> Void
    let updatePassword: () -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditPasswordPage(password: password, addPassword: addPassword, updatePassword: updatePassword)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
