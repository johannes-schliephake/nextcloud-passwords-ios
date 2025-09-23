import SwiftUI
import Factory


struct ServerSetupNavigation: View {
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            ServerSetupPage(viewModel: resolve(\.serverSetupViewModelType).init().eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
