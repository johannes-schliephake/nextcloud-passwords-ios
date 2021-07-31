import SwiftUI


struct SelectFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entry: Entry
    let temporaryEntry: SelectFolderController.TemporaryEntry
    let folders: [Folder]
    let selectFolder: (Folder) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SelectFolderPage(entry: entry, temporaryEntry: temporaryEntry, folders: folders, selectFolder: selectFolder)
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
