import SwiftUI
import FactoryKit


struct SettingsNavigation: View {
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            SettingsPage(viewModel: dependency(\.settingsViewModelType).init().eraseToAnyViewModel())
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
