import SwiftUI


@main
struct PasswordsApp: App {
    
    @StateObject private var autoFillController = ProcessInfo.processInfo.environment["TEST"] == "true" ? AutoFillController.mock : AutoFillController()
    
    // MARK: Views
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(autoFillController)
        }
    }
    
}
