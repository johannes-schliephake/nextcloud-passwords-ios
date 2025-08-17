import SwiftUI
import Factory


struct SelectTagsNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let temporaryEntry: SelectTagsViewModel.TemporaryEntry
    let selectTags: ([Tag], [String]) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SelectTagsPage(viewModel: resolve(\.selectTagsViewModelType).init(temporaryEntry: temporaryEntry, selectTags: selectTags).eraseToAnyViewModel())
        }
        .showColumns(false)
        .scrollDismissesKeyboard(.interactively)
        .occlude(biometricAuthenticationController.hideContents)
    }
    
}
