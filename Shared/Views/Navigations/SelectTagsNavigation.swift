import SwiftUI
import Factory


struct SelectTagsNavigation: View {
    
    let temporaryEntry: SelectTagsViewModel.TemporaryEntry
    let selectTags: ([Tag], [String]) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            SelectTagsPage(viewModel: resolve(\.selectTagsViewModelType).init(temporaryEntry: temporaryEntry, selectTags: selectTags).eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
