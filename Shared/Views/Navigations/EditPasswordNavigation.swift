import SwiftUI


struct EditPasswordNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let password: Password
    let folders: [Folder]
    let addPassword: () -> Void
    let updatePassword: () -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditPasswordPage(password: password, folders: folders, addPassword: addPassword, updatePassword: updatePassword)
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
