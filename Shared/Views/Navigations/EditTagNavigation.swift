import SwiftUI


struct EditTagNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    let entriesController: EntriesController
    let tag: Tag
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            EditTagPage(entriesController: entriesController, tag: tag)
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
