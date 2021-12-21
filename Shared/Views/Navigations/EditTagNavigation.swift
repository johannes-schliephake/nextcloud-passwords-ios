import SwiftUI


struct EditTagNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let tag: Tag
    let addTag: () -> Void
    let updateTag: () -> Void
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                EditTagPage(tag: tag, addTag: addTag, updateTag: updateTag)
            }
            else {
                EditTagPageFallback(tag: tag, addTag: addTag, updateTag: updateTag)
            }
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
