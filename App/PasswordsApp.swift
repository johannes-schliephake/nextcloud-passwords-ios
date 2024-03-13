import SwiftUI
import Factory


@main struct PasswordsApp: App {
    
    @StateObject private var autoFillController = Configuration.isTestEnvironment ? AutoFillController.mock : AutoFillController.default
    
    init() {
        _ = resolve(\.logger)
        _ = resolve(\.windowSizeDataSource)
    }
    
    // MARK: Views
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(autoFillController)
                .onAppear {
                    NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
                }
        }
    }
    
}
