import SwiftUI
import Factory


struct EditFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let folder: Folder
    var didEdit: ((Folder) -> Void)?
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditFolderPage(viewModel: resolve(\.editFolderViewModelType).init(folder: folder, didEdit: didEdit).eraseToAnyViewModel())
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
