import SwiftUI


struct SelectTagsNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let temporaryEntry: SelectTagsController.TemporaryEntry
    let selectTags: ([Tag], [String]) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                SelectTagsPage(entriesController: entriesController, temporaryEntry: temporaryEntry, selectTags: selectTags)
            }
            else {
                SelectTagsPageFallback(entriesController: entriesController, temporaryEntry: temporaryEntry, selectTags: selectTags)
            }
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
