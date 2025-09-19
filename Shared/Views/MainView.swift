import SwiftUI
import Factory
import Combine


struct MainView: View {
    
    @StateObject private var authenticationChallengeController = resolve(\.authenticationChallengeController)
    @StateObject private var globalAlertsViewModel = GlobalAlertsViewModel().eraseToAnyViewModel()
    
    // MARK: Views
    
    var body: some View {
        EntriesNavigation()
            .onChange(of: authenticationChallengeController.certificateConfirmationRequests, perform: didChange)
            .copyToast()
            .environmentObject(resolve(\.autoFillController))
            .environmentObject(resolve(\.biometricAuthenticationController))
            .environmentObject(resolve(\.sessionController))
            .environmentObject(resolve(\.settingsController))
            .onAppear {
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
                
                if #available(iOS 26, *),
                   let serviceUrl = resolve(\.autoFillController).serviceURLs?.first {
                    @Injected(\.urlLabelSuggestionRepository) var urlLabelSuggestionRepository
                    urlLabelSuggestionRepository(.setUrl(serviceUrl))
                }
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
