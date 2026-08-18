import SwiftUI
import FactoryKit


struct EditTagNavigation: View {
    
    let tag: Tag
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EditTagPage(viewModel: dependency(\.editTagViewModelType).init(tag: tag).eraseToAnyViewModel())
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
