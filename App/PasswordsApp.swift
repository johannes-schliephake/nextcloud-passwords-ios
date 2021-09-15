import SwiftUI


@main struct PasswordsApp: App {
    
    @StateObject private var autoFillController = Configuration.isTestEnvironment ? AutoFillController.mock : AutoFillController()
    
    // MARK: Views
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(autoFillController)
                .onAppear {
                    NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
                }
        }
    }
    
}
