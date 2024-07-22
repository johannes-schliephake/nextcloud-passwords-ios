import Factory


@available(iOS 17, *) protocol OpenProviderSettingsUseCaseProtocol: UseCase where State == EmptyState, Action == OpenProviderSettingsUseCase.Action {}


@available(iOS 17, *) final class OpenProviderSettingsUseCase: OpenProviderSettingsUseCaseProtocol {
    
    enum Action {
        case open
    }
    
    @LazyInjected(\.credentialProviderSettingsHelperType) private var credentialProviderSettingsHelperType
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .open:
            credentialProviderSettingsHelperType.openCredentialProviderAppSettings()
        }
    }
    
}
