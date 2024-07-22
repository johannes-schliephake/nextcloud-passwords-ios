import AuthenticationServices


protocol CredentialProviderSettingsHelping {
    
    static func openCredentialProviderAppSettings(completionHandler: (((any Error)?) -> Void)?)
    
}


extension CredentialProviderSettingsHelping {
    
    static func openCredentialProviderAppSettings() {
        openCredentialProviderAppSettings(completionHandler: nil)
    }
    
}


@available(iOS 17, *) extension ASSettingsHelper: CredentialProviderSettingsHelping {}
