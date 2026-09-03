import SwiftUI
import FactoryKit


struct ServerSetupNavigation: View {
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            ServerSetupPage(viewModel: dependency(\.serverSetupViewModelType).init().eraseToAnyViewModel())
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
