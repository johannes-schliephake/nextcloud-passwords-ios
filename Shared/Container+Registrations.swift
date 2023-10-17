import Factory
import CoreImage
import AVFoundation
import StoreKit


extension Container {
    
    // MARK: ViewModels
    var captureOTPViewModelType: Factory<any CaptureOTPViewModelProtocol.Type> {
        self { CaptureOTPViewModel.self }
    }
    var editFolderViewModelType: Factory<any EditFolderViewModelProtocol.Type> {
        self { EditFolderViewModel.self }
    }
    var editOTPViewModelType: Factory<any EditOTPViewModelProtocol.Type> {
        self { EditOTPViewModel.self }
    }
    var editTagViewModelType: Factory<any EditTagViewModelProtocol.Type> {
        self { EditTagViewModel.self }
    }
    var globalAlertsViewModelType: Factory<any GlobalAlertsViewModelProtocol.Type> {
        self { GlobalAlertsViewModel.self }
    }
    var logViewModelType: Factory<any LogViewModelProtocol.Type> {
        self { LogViewModel.self }
    }
    var selectFolderViewModelType: Factory<any SelectFolderViewModelProtocol.Type> {
        self { SelectFolderViewModel.self }
    }
    var selectTagsViewModelType: Factory<any SelectTagsViewModelProtocol.Type> {
        self { SelectTagsViewModel.self }
    }
    var settingsViewModelType: Factory<any SettingsViewModelProtocol.Type> {
        self { SettingsViewModel.self }
    }
    var shareOTPViewModelType: Factory<any ShareOTPViewModelProtocol.Type> {
        self { ShareOTPViewModel.self }
    }
    
    // MARK: Services
    var folderValidationService: Factory<any FolderValidationServiceProtocol> {
        self { FolderValidationService() }
            .cached
    }
    var foldersService: Factory<any FoldersServiceProtocol> {
        self { FoldersService() }
            .cached
    }
    var otpService: Factory<any OTPServiceProtocol> {
        self { OTPService() }
            .cached
    }
    var otpValidationService: Factory<any OTPValidationServiceProtocol> {
        self { OTPValidationService() }
            .cached
    }
    var pasteboardService: Factory<any PasteboardServiceProtocol> {
        self { PasteboardService() }
            .cached
    }
    var purchaseService: Factory<any PurchaseServiceProtocol> {
        self { PurchaseService() }
            .cached
    }
    var qrCodeService: Factory<any QRCodeServiceProtocol> {
        self { QRCodeService() }
            .cached
    }
    var sessionService: Factory<any SessionServiceProtocol> {
        self { SessionService() }
            .cached
    }
    var settingsService: Factory<any SettingsServiceProtocol> {
        self { SettingsService() }
            .cached
    }
    var tagValidationService: Factory<any TagValidationServiceProtocol> {
        self { TagValidationService() }
            .cached
    }
    var tagsService: Factory<any TagsServiceProtocol> {
        self { TagsService() }
            .cached
    }
    var torchService: Factory<any TorchServiceProtocol> {
        self { TorchService() }
    }
    var windowSizeService: Factory<any WindowSizeServiceProtocol> {
        self { WindowSizeService() }
            .cached
    }
    
    // MARK: Repositories
    var pasteboardDataSource: Factory<any PasteboardDataSourceProtocol> {
        self { PasteboardDataSource() }
            .cached
    }
    var pasteboardRepository: Factory<any PasteboardRepositoryProtocol> {
        self { PasteboardRepository() }
            .cached
    }
    var productIdentifiersPropertyListDataSource: Factory<any ProductIdentifiersPropertyListDataSourceProtocol> {
        self { ProductIdentifiersPropertyListDataSource() }
            .cached
    }
    var productIdentifiersRepository: Factory<any ProductIdentifiersRepositoryProtocol> {
        self { ProductIdentifiersRepository() }
            .cached
    }
    var productsAppStoreDataSource: Factory<any ProductsAppStoreDataSourceProtocol> {
        self { ProductsAppStoreDataSource() }
            .cached
    }
    var productsRepository: Factory<any ProductsRepositoryProtocol> {
        self { ProductsRepository() }
            .cached
    }
    
    // MARK: Helpers
    var logger: Factory<any Logging> {
        self { Logger() }
            .cached
    }
    
    // MARK: Seams
    var appStoreType: Factory<any AppStore.Type> {
        self { StoreKit.AppStore.self }
    }
    var pasteboard: Factory<any Pasteboard> {
        self { UIPasteboard.general }
    }
    var productType: Factory<any Product.Type> {
        self { StoreKit.Product.self }
    }
    var qrCodeGenerator: Factory<(any QRCodeGenerating)?> {
        self { CIFilter(name: "CIQRCodeGenerator") }
    }
    var transactionType: Factory<any Transaction.Type> {
        self { StoreKit.Transaction.self }
    }
    var videoCapturer: Factory<(any VideoCapturing)?> {
        self { AVCaptureDevice.default(for: .video) }
    }
    
    // MARK: Miscellaneous
    var configurationType: Factory<any Configurating.Type> {
        self { Configuration.self }
    }
    var currentDate: Factory<Date> {
        self { .init() }
    }
    
    // TODO: remove
    var entriesController: Factory<EntriesController> {
        self { .init() }
            .cached
    }
    
}
