import SwiftUI
import Factory


struct SelectFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entry: Entry
    let temporaryEntry: SelectFolderViewModel.TemporaryEntry
    let selectFolder: (Folder) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SelectFolderPage(viewModel: resolve(\.selectFolderViewModelType).init(entry: entry, temporaryEntry: temporaryEntry, selectFolder: selectFolder).eraseToAnyViewModel())
        }
        .showColumns(false)
        .scrollDismissesKeyboard(.interactively)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
