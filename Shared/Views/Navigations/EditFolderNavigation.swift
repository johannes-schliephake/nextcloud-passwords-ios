import SwiftUI


struct EditFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let folder: Folder
    var didAdd: ((Folder) -> Void)?
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                EditFolderPage(entriesController: entriesController, folder: folder, didAdd: didAdd)
            }
            else {
                EditFolderPageFallback(entriesController: entriesController, folder: folder, didAdd: didAdd)
            }
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
