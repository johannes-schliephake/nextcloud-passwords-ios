@testable import Passwords
import Factory


@available(iOS 17, *) final class CredentialProviderSettingsHelperMock: CredentialProviderSettingsHelping, Mock, FunctionCallLogging {
    
    static var _openCredentialProviderAppSettingsCompletionHandler: (any Error)?? // swiftlint:disable:this identifier_name
    static func openCredentialProviderAppSettings(completionHandler: (((any Error)?) -> Void)?) {
        logFunctionCall()
        _openCredentialProviderAppSettingsCompletionHandler.map { completionHandler?($0) }
    }
    
}
