import SwiftUI


struct SelectFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let entry: Entry
    let temporaryEntry: SelectFolderController.TemporaryEntry
    let selectFolder: (Folder) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SelectFolderPage(entriesController: entriesController, entry: entry, temporaryEntry: temporaryEntry, selectFolder: selectFolder)
        }
        .showColumns(false)
        .apply {
            view in
            if #available(iOS 16, *) {
                view
                    .scrollDismissesKeyboard(.interactively)
            }
        }
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
