import Factory
@testable import Passwords


extension Container: AutoRegistering {
    
    public func autoRegister() {
        //Self.shared.appStoreType.register { AppStoreMock.self }
        Self.shared.captureOTPViewModelType.register { CaptureOTPViewModelMock.self }
        Self.shared.configurationType.register { ConfigurationMock.self }
        Self.shared.currentDate.singleton.register { .init() }
        Self.shared.editFolderViewModelType.register { EditFolderViewModelMock.self }
        Self.shared.editOTPViewModelType.register { EditOTPViewModelMock.self }
        Self.shared.editTagViewModelType.register { EditTagViewModelMock.self }
        Self.shared.folderValidationService.register { FolderValidationServiceMock() }
        Self.shared.foldersService.register { FoldersServiceMock() }
        //Self.shared.globalAlertsViewModelType.register { GlobalAlertsViewModelMock.self }
        Self.shared.logger.register { LoggerMock() }
        Self.shared.logViewModelType.register { LogViewModelMock.self }
        Self.shared.otpService.register { OTPServiceMock() }
        Self.shared.otpValidationService.register { OTPValidationServiceMock() }
        Self.shared.pasteboardService.register { PasteboardServiceMock() }
        //Self.shared.productIdentifiersPropertyListDataSource.register { ProductIdentifiersPropertyListDataSourceMock() }
        //Self.shared.productIdentifiersRepository.register { ProductIdentifiersRepositoryMock() }
        //Self.shared.productsAppStoreDataSource.register { ProductsAppStoreDataSourceMock() }
        //Self.shared.productsRepository.register { ProductsRepositoryMock() }
        Self.shared.productType.register { ProductMock.self }
        Self.shared.purchaseService.register { PurchaseServiceMock() }
        Self.shared.qrCodeGenerator.cached.register { QRCodeGeneratorMock() }
        Self.shared.qrCodeService.register { QRCodeServiceMock() }
        Self.shared.selectFolderViewModelType.register { SelectFolderViewModelMock.self }
        Self.shared.selectTagsViewModelType.register { SelectTagsViewModelMock.self }
        Self.shared.sessionService.register { SessionServiceMock() }
        Self.shared.settingsService.register { SettingsServiceMock() }
        Self.shared.settingsViewModelType.register { SettingsViewModelMock.self }
        Self.shared.shareOTPViewModelType.register { ShareOTPViewModelMock.self }
        Self.shared.tagValidationService.register { TagValidationServiceMock() }
        Self.shared.tagsService.register { TagsServiceMock() }
        Self.shared.torchService.cached.register { TorchServiceMock() }
        //Self.shared.transactionType.register { TransactionMock.self }
        Self.shared.videoCapturer.cached.register { VideoCapturerMock() }
        
        // TODO: remove
        Self.shared.entriesController.register { .mock }
    }
    
}
