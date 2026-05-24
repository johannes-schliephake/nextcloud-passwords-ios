import SwiftUI
import FactoryKit


struct EditFolderNavigation: View {
    
    let folder: Folder
    var didEdit: ((Folder) -> Void)?
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EditFolderPage(viewModel: dependency(\.editFolderViewModelType).init(folder: folder, didEdit: didEdit).eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
