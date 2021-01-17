import SwiftUI


struct EditFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let folder: Folder
    let addFolder: () -> Void
    let updateFolder: () -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditFolderPage(folder: folder, addFolder: addFolder, updateFolder: updateFolder)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
