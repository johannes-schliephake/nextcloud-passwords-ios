import SwiftUI
import Factory


struct EditTagNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let tag: Tag
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditTagPage(viewModel: resolve(\.editTagViewModelType).init(tag: tag).eraseToAnyViewModel())
        }
        .showColumns(false)
        .scrollDismissesKeyboard(.interactively)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
