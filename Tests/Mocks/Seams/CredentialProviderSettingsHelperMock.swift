@testable import Passwords
import FactoryKit


@available(iOS 17, *) final class CredentialProviderSettingsHelperMock: CredentialProviderSettingsHelping, Mock, FunctionCallLogging {
    
    static var _openCredentialProviderAppSettingsCompletionHandler: (((any Error)?) -> Void)?? // swiftlint:disable:this identifier_name
    static func openCredentialProviderAppSettings(completionHandler: (((any Error)?) -> Void)?) {
        logFunctionCall()
        _openCredentialProviderAppSettingsCompletionHandler = completionHandler
    }
    
}
