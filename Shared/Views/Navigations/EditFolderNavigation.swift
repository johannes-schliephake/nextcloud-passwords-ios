import SwiftUI
import Factory


struct EditFolderNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let folder: Folder
    var didEdit: ((Folder) -> Void)?
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EditFolderPage(viewModel: resolve(\.editFolderViewModelType).init(folder: folder, didEdit: didEdit).eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
