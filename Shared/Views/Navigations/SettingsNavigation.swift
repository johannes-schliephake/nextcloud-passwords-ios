import SwiftUI
import Factory


struct SettingsNavigation: View {
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            SettingsPage(viewModel: resolve(\.settingsViewModelType).init().eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
