import SwiftUI


struct SelectFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entry: Entry
    let temporaryEntry: SelectFolderViewModel.TemporaryEntry
    let selectFolder: (Folder) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SelectFolderPage(viewModel: SelectFolderViewModel(entry: entry, temporaryEntry: temporaryEntry, selectFolder: selectFolder).eraseToAnyViewModel())
        }
        .showColumns(false)
        .apply {
            view in
            if #available(iOS 16, *) {
                view
                    .scrollDismissesKeyboard(.interactively)
            }
        }
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
