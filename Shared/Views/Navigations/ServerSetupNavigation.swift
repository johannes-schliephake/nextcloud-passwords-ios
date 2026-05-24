import SwiftUI
import FactoryKit


struct ServerSetupNavigation: View {
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            ServerSetupPage(viewModel: dependency(\.serverSetupViewModelType).init().eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
