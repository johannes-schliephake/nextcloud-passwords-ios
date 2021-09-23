import SwiftUI


struct ServerSetupNavigation: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                ServerSetupPage()
            }
            else {
                ServerSetupPageFallback()
            }
        }
        .showColumns(false)
        .occlude(!biometricAuthenticationController.isUnlocked)
    }
    
}
