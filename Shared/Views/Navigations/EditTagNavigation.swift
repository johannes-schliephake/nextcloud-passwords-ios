import SwiftUI
import Factory


struct EditTagNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let tag: Tag
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EditTagPage(viewModel: resolve(\.editTagViewModelType).init(tag: tag).eraseToAnyViewModel())
        }
        .scrollDismissesKeyboard(.immediately)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
