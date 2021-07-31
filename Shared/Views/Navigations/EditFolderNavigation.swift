import SwiftUI


struct EditFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let folder: Folder
    let folders: [Folder]
    let addFolder: () -> Void
    let updateFolder: () -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditFolderPage(folder: folder, folders: folders, addFolder: addFolder, updateFolder: updateFolder)
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
