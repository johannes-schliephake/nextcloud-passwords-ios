import SwiftUI


struct EditFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let folder: Folder
    var didAdd: ((Folder) -> Void)?
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditFolderPage(entriesController: entriesController, folder: folder, didAdd: didAdd)
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
