import SwiftUI
import FactoryKit


struct SelectFolderNavigation: View {
    
    let entry: Entry
    let temporaryEntry: SelectFolderViewModel.TemporaryEntry
    let selectFolder: (Folder) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            SelectFolderPage(viewModel: dependency(\.selectFolderViewModelType).init(entry: entry, temporaryEntry: temporaryEntry, selectFolder: selectFolder).eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
