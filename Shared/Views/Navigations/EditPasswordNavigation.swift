import SwiftUI


struct EditPasswordNavigation: View {
    
    let entriesController: EntriesController
    let password: Password
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EditPasswordPage(entriesController: entriesController, password: password)
        }
        .apply { view in
            if #available(iOS 26, *) {
                view
                    .scrollEdgeEffectStyle(.soft, for: .top)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
