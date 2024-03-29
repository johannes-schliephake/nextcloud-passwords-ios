import Factory
@testable import Passwords


extension Container: AutoRegistering {
    
    public func autoRegister() {
        
        // MARK: ViewModels
        Self.shared.captureOTPViewModelType.register { CaptureOTPViewModelMock.self }
        Self.shared.editFolderViewModelType.register { EditFolderViewModelMock.self }
        Self.shared.editOTPViewModelType.register { EditOTPViewModelMock.self }
        Self.shared.editTagViewModelType.register { EditTagViewModelMock.self }
        //Self.shared.globalAlertsViewModelType.register { GlobalAlertsViewModelMock.self }
        Self.shared.logViewModelType.register { LogViewModelMock.self }
        Self.shared.selectFolderViewModelType.register { SelectFolderViewModelMock.self }
        Self.shared.selectTagsViewModelType.register { SelectTagsViewModelMock.self }
        Self.shared.settingsViewModelType.register { SettingsViewModelMock.self }
        Self.shared.shareOTPViewModelType.register { ShareOTPViewModelMock.self }
        
        // MARK: Services
        Self.shared.folderValidationService.register { FolderValidationServiceMock() }
        Self.shared.foldersService.register { FoldersServiceMock() }
        Self.shared.otpService.register { OTPServiceMock() }
        Self.shared.otpValidationService.register { OTPValidationServiceMock() }
        Self.shared.pasteboardService.register { PasteboardServiceMock() }
        Self.shared.purchaseService.register { PurchaseServiceMock() }
        Self.shared.qrCodeService.register { QRCodeServiceMock() }
        Self.shared.sessionService.register { SessionServiceMock() }
        Self.shared.settingsService.register { SettingsServiceMock() }
        Self.shared.tagValidationService.register { TagValidationServiceMock() }
        Self.shared.tagsService.register { TagsServiceMock() }
        Self.shared.torchService.cached.register { TorchServiceMock() }
        //Self.shared.windowSizeService.register { WindowSizeServiceMock() }
        
        // MARK: Repositories
        Self.shared.pasteboardDataSource.register { PasteboardDataSourceMock() }
        Self.shared.pasteboardRepository.register { PasteboardRepositoryMock() }
        //Self.shared.productIdentifiersPropertyListDataSource.register { ProductIdentifiersPropertyListDataSourceMock() }
        //Self.shared.productIdentifiersRepository.register { ProductIdentifiersRepositoryMock() }
        //Self.shared.productsAppStoreDataSource.register { ProductsAppStoreDataSourceMock() }
        //Self.shared.productsRepository.register { ProductsRepositoryMock() }
        
        // MARK: Helpers
        Self.shared.logger.register { LoggerMock() }
        
        // MARK: Seams
        //Self.shared.appStoreType.register { AppStoreMock.self }
        Self.shared.pasteboard.cached.register { PasteboardMock() }
        Self.shared.productType.register { ProductMock.self }
        Self.shared.qrCodeGenerator.cached.register { QRCodeGeneratorMock() }
        //Self.shared.transactionType.register { TransactionMock.self }
        Self.shared.videoCapturer.cached.register { VideoCapturerMock() }
        
        // MARK: Miscellaneous
        Self.shared.configurationType.register { ConfigurationMock.self }
        Self.shared.currentDate.singleton.register { .init() }
        
        // TODO: remove
        Self.shared.entriesController.register { .mock }
    }
    
}
