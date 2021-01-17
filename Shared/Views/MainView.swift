import SwiftUI
import StoreKit


struct MainView: View {
    
    @EnvironmentObject private var autoFillController: AutoFillController
    
    @StateObject private var biometricAuthenticationController = ProcessInfo.processInfo.environment["TEST"] == "true" ? BiometricAuthenticationController.mock : BiometricAuthenticationController()
    @StateObject private var credentialsController = ProcessInfo.processInfo.environment["TEST"] == "true" ? CredentialsController.mock : CredentialsController.default
    @StateObject private var tipController = ProcessInfo.processInfo.environment["TEST"] == "true" ? TipController.mock : TipController()
    
    // MARK: Views
    
    var body: some View {
        EntriesNavigation()
            .onChange(of: tipController.transactionState, perform: transactionStateDidChange)
            .copyToast()
            .environmentObject(autoFillController)
            .environmentObject(biometricAuthenticationController)
            .environmentObject(credentialsController)
            .environmentObject(tipController)
    }
    
    // MARK: Functions
    
    private func transactionStateDidChange(transactionState: SKPaymentTransactionState?) {
        guard let transactionState = transactionState else {
            return
        }
        switch transactionState {
        case .deferred:
            UIAlertController.presentGlobalAlert(title: "_tipDeferred".localized, message: "_tipDeferredMessage".localized) {
                tipController.transactionState = nil
            }
        case .purchased, .restored:
            UIAlertController.presentGlobalAlert(title: "_tipReceived".localized, message: "_tipReceivedMessage".localized, dismiss: "_highFive".localized) {
                tipController.transactionState = nil
            }
        case .failed:
            UIAlertController.presentGlobalAlert(title: "_tipFailed".localized, message: "_tipFailedMessage".localized) {
                tipController.transactionState = nil
            }
        case .purchasing:
            return
        @unknown default:
            return
        }
    }
    
}
