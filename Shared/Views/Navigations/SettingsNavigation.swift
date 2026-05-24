import SwiftUI
import FactoryKit


struct SettingsNavigation: View {
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            SettingsPage(viewModel: dependency(\.settingsViewModelType).init().eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
