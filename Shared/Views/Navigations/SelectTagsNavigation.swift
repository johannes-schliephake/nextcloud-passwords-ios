import SwiftUI
import FactoryKit


struct SelectTagsNavigation: View {
    
    let temporaryEntry: SelectTagsViewModel.TemporaryEntry
    let selectTags: ([Tag], [String]) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            SelectTagsPage(viewModel: dependency(\.selectTagsViewModelType).init(temporaryEntry: temporaryEntry, selectTags: selectTags).eraseToAnyViewModel())
        }
        .apply { view in
            if #available(iOS 26, *) {
                view
                    .scrollEdgeEffectStyle(.soft, for: .all)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
