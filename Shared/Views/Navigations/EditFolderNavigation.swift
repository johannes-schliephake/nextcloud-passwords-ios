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
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                EditFolderPage(folder: folder, folders: folders, addFolder: addFolder, updateFolder: updateFolder)
            }
            else {
                EditFolderPageFallback(folder: folder, folders: folders, addFolder: addFolder, updateFolder: updateFolder)
            }
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
