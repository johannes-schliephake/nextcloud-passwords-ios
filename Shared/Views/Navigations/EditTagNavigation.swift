import SwiftUI
import FactoryKit


struct EditTagNavigation: View {
    
    let tag: Tag
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EditTagPage(viewModel: dependency(\.editTagViewModelType).init(tag: tag).eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
