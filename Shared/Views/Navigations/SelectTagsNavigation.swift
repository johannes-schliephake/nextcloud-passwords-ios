import SwiftUI


struct SelectTagsNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let temporaryEntry: SelectTagsController.TemporaryEntry
    let selectTags: ([Tag], [String]) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            SelectTagsPage(entriesController: entriesController, temporaryEntry: temporaryEntry, selectTags: selectTags)
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
