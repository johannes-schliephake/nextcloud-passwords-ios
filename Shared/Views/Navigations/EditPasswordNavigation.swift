import SwiftUI


struct EditPasswordNavigation: View {
    
    let entriesController: EntriesController
    let password: Password
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EditPasswordPage(entriesController: entriesController, password: password)
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
