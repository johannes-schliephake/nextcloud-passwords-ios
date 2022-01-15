import SwiftUI


struct EditTagNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let tag: Tag
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                EditTagPage(entriesController: entriesController, tag: tag)
            }
            else {
                EditTagPageFallback(entriesController: entriesController, tag: tag)
            }
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
