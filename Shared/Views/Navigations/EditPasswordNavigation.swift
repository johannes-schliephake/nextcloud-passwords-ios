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
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                EditPasswordPage(password: password, folders: folders, addPassword: addPassword, updatePassword: updatePassword)
            }
            else {
                EditPasswordPageFallback(password: password, folders: folders, addPassword: addPassword, updatePassword: updatePassword)
            }
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
