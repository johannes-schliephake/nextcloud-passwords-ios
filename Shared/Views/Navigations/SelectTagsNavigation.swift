import SwiftUI


struct SelectTagsNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let temporaryEntry: SelectTagsController.TemporaryEntry
    let tags: [Tag]
    let addTag: (Tag) -> Void
    let selectTags: ([Tag], [String]) -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                SelectTagsPage(temporaryEntry: temporaryEntry, tags: tags, addTag: addTag, selectTags: selectTags)
            }
            else {
                SelectTagsPageFallback(temporaryEntry: temporaryEntry, tags: tags, addTag: addTag, selectTags: selectTags)
            }
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
