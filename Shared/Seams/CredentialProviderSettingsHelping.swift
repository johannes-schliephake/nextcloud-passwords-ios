import AuthenticationServices


protocol CredentialProviderSettingsHelping {
    
    static func openCredentialProviderAppSettings(completionHandler: (@Sendable (any Error?) -> Void)?)
    
}


extension CredentialProviderSettingsHelping {
    
    static func openCredentialProviderAppSettings() {
        openCredentialProviderAppSettings(completionHandler: nil)
    }
    
}


extension ASSettingsHelper: CredentialProviderSettingsHelping {}
