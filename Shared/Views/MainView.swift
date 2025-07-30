import SwiftUI
import Factory
import Combine


struct MainView: View {
    
    @EnvironmentObject private var autoFillController: AutoFillController
    
    @StateObject private var authenticationChallengeController = AuthenticationChallengeController.default
    @StateObject private var biometricAuthenticationController = Configuration.isTestEnvironment ? BiometricAuthenticationController.mock : BiometricAuthenticationController()
    @StateObject private var sessionController = Configuration.isTestEnvironment ? SessionController.mock : SessionController.default
    @StateObject private var settingsController = Configuration.isTestEnvironment ? SettingsController.mock : SettingsController.default
    @StateObject private var globalAlertsViewModel = GlobalAlertsViewModel().eraseToAnyViewModel()
    
    // MARK: Views
    
    var body: some View {
        EntriesNavigation()
            .onChange(of: authenticationChallengeController.certificateConfirmationRequests, perform: didChange)
            .copyToast()
            .environmentObject(biometricAuthenticationController)
            .environmentObject(sessionController)
            .environmentObject(settingsController)
            .onAppear {
                biometricAuthenticationController.autoFillController = autoFillController
                
                Task {
                    do {
                        @Injected(\.prepareWordlistUseCase) var prepareWordlistUseCase
                        try await Just(())
                            .handle(with: prepareWordlistUseCase, .prepareWordlist, publishing: \.$preparationSignal)
                            .values
                            .first()
                    } catch {
                        @Injected(\.logger) var logger
                        logger.log(error: error)
                    }
                }
            }
            .onDisappear {
                /// In some specific situations SwiftUI doesn't reliably deallocate StateObjects. Most of the time this "just" is a memory leak, but in case of the BiometricAuthenticationController it also results in unwanted biometric evaluation calls. Therefore all notification subscriptions have to be manually cancelled through the invalidate function.
                biometricAuthenticationController.invalidate()
            }
    }
    
    // MARK: Functions
    
    private func didChange(certificateConfirmationRequests: [AuthenticationChallengeController.CertificateConfirmationRequest]) {
        guard let certificateConfirmationRequest = certificateConfirmationRequests.first else {
            return
        }
        UIAlertController.presentGlobalAlert(title: "_invalidCertificate".localized, message: String(format: "_invalidCertificateMessage(hash)".localized, certificateConfirmationRequest.hash), dismissText: "_reject".localized, dismissHandler: {
            authenticationChallengeController.deny(certificateHash: certificateConfirmationRequest.hash)
        }, confirmText: "_accept".localized, confirmHandler: {
            authenticationChallengeController.accept(certificateHash: certificateConfirmationRequest.hash)
        }, destructive: true)
    }
    
}
