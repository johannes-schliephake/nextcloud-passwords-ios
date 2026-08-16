import FactoryKit
@testable import Passwords


extension Container: @retroactive AutoRegistering {
    
    public func autoRegister() {
        Self.shared { // swiftlint:disable anonymous_argument_in_multiline_closure
            
            // MARK: ViewModels
            $0.captureOTPViewModelType { CaptureOTPViewModelMock.self }
            $0.editFolderViewModelType { EditFolderViewModelMock.self }
            $0.editOTPViewModelType { EditOTPViewModelMock.self }
            $0.editTagViewModelType { EditTagViewModelMock.self }
            //$0.globalAlertsViewModelType { GlobalAlertsViewModelMock.self }
            $0.logViewModelType { LogViewModelMock.self }
            $0.selectFolderViewModelType { SelectFolderViewModelMock.self }
            $0.selectTagsViewModelType { SelectTagsViewModelMock.self }
            $0.serverSetupViewModelType { ServerSetupViewModelMock.self }
            $0.settingsViewModelType { SettingsViewModelMock.self }
            $0.shareOTPViewModelType { ShareOTPViewModelMock.self }
            
            // MARK: UseCases
            $0.authenticationUseCase { AuthenticationUseCaseMock() }
            $0.folderLabelUseCase.cached { FolderLabelUseCaseMock() }
            //$0.generatePasswordUseCase.cached { GeneratePasswordUseCaseMock() }
            $0.initiateLoginUseCase.cached { InitiateLoginUseCaseMock() }
            $0.loginPollUseCase.cached { LoginPollUseCaseMock() }
            $0.loginUrlUseCase.cached { LoginUrlUseCaseMock() }
            $0.managedConfigurationUseCase { ManagedConfigurationUseCaseMock() }
            if #available(iOS 17, *) {
                $0.openProviderSettingsUseCase.cached { OpenProviderSettingsUseCaseMock() }
            }
            //$0.preferredUsernameUseCase { PreferredUsernameUseCaseMock() }
            //$0.prepareWordlistUseCase { PrepareWordlistUseCaseMock() }
            //$0.randomWordUseCase.cached { RandomWordUseCaseMock() }
            $0.windowSizeUseCase { WindowSizeUseCaseMock() }
            //$0.wordlistLocaleUseCase { WordlistLocaleUseCaseMock() }
            
            // MARK: Services
            $0.folderValidationService { FolderValidationServiceMock() }
            $0.foldersService { FoldersServiceMock() }
            $0.otpService { OTPServiceMock() }
            $0.otpValidationService { OTPValidationServiceMock() }
            $0.pasteboardService { PasteboardServiceMock() }
            $0.purchaseService { PurchaseServiceMock() }
            $0.qrCodeService { QRCodeServiceMock() }
            $0.sessionService { SessionServiceMock() }
            $0.settingsService { SettingsServiceMock() }
            $0.tagValidationService { TagValidationServiceMock() }
            $0.tagsService { TagsServiceMock() }
            
            // MARK: Repositories
            //$0.onDemandResourcesPropertyListDataSource { OnDemandResourcesPropertyListDataSourceMock() }
            //$0.onDemandResourcesRepository { OnDemandResourcesRepositoryMock() }
            $0.pasteboardDataSource { PasteboardDataSourceMock() }
            $0.pasteboardRepository { PasteboardRepositoryMock() }
            //$0.productIdentifiersPropertyListDataSource { ProductIdentifiersPropertyListDataSourceMock() }
            //$0.productIdentifiersRepository { ProductIdentifiersRepositoryMock() }
            //$0.productsAppStoreDataSource { ProductsAppStoreDataSourceMock() }
            //$0.productsRepository { ProductsRepositoryMock() }
    //        if #available(iOS 26, *) {
                //$0.urlLabelSuggestionLanguageModelDataSource.cached { UrlLabelSuggestionLanguageModelDataSourceMock() }
                //$0.urlLabelSuggestionRepository { UrlLabelSuggestionRepositoryMock() }
    //        }
            $0.windowDataSource { WindowDataSourceMock() }
            $0.windowRepository { WindowRepositoryMock() }
            //$0.wordlistDataSource.cached { WordlistDataSourceMock() }
            //$0.wordlistPreparationDataSource { WordlistPreparationDataSourceMock() }
            //$0.wordlistRepository.cached { WordlistRepositoryMock() }
            
            // MARK: Helpers
            $0.logger { LoggerMock() }
            
            // MARK: Seams
            //$0.appStoreType { AppStoreMock.self }
            //$0.bundleResourceRequestType { BundleResourceRequestMock.self }
            if #available(iOS 17, *) {
                $0.credentialProviderSettingsHelperType.cached {
                    CredentialProviderSettingsHelperMock.removeAssociated()
                    return CredentialProviderSettingsHelperMock.self
                }
            }
    //        if #available(iOS 26, *) {
                //$0.defaultLanguageModelType { DefaultLanguageModelMock.self }
    //        }
            //$0.fileHandleType { FileHandleMock.self }
            //$0.fileManager.cached { FileManagerMock() }
            $0.pasteboard.cached { PasteboardMock() }
            $0.productType { ProductMock.self }
            $0.qrCodeGenerator.cached { QRCodeGeneratorMock() }
            //$0.randomNumberGenerator.cached { RandomNumberGeneratorMock() }
            $0.systemNotifications.cached { NotificationsMock() }
            //$0.transactionType { TransactionMock.self }
            $0.webAuthenticationSessionType { WebAuthenticationSessionMock.self }
            
            // MARK: Miscellaneous
            $0.configurationType { ConfigurationMock.self }
            //$0.cryptoSHA256Type { CryptoSHA256Mock.self }
            $0.currentDate.singleton { .init() }
            $0.mainScheduler { dependency(\.mainSchedulerMock).eraseToAnyScheduler() }
            $0.userInitiatedScheduler { dependency(\.userInitiatedSchedulerMock).eraseToAnyScheduler() }
        } // swiftlint:enable anonymous_argument_in_multiline_closure
    }
    
}
