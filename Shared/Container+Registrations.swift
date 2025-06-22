import Factory
import CoreImage
import AVFoundation
import StoreKit
import CombineSchedulers
import WebKit
import AuthenticationServices
import Sodium


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
    var loginFlowViewModelType: Factory<any LoginFlowViewModelProtocol.Type> {
        self { LoginFlowViewModel.self }
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
    var serverSetupViewModelType: Factory<any ServerSetupViewModelProtocol.Type> {
        self { ServerSetupViewModel.self }
    }
    var settingsViewModelType: Factory<any SettingsViewModelProtocol.Type> {
        self { SettingsViewModel.self }
    }
    var shareOTPViewModelType: Factory<any ShareOTPViewModelProtocol.Type> {
        self { ShareOTPViewModel.self }
    }
    
    // MARK: UseCases
    var checkLoginGrantUseCase: Factory<any CheckLoginGrantUseCaseProtocol> {
        self { CheckLoginGrantUseCase() }
    }
    var checkTrustUseCase: Factory<any CheckTrustUseCaseProtocol> {
        self { CheckTrustUseCase() }
    }
    var folderLabelUseCase: Factory<any FolderLabelUseCaseProtocol> {
        self { FolderLabelUseCase() }
    }
    var generatePasswordUseCase: Factory<any GeneratePasswordUseCaseProtocol> {
        self { GeneratePasswordUseCase() }
    }
    var initiateLoginUseCase: Factory<any InitiateLoginUseCaseProtocol> {
        self { InitiateLoginUseCase() }
    }
    var loginPollUseCase: Factory<any LoginPollUseCaseProtocol> {
        self { LoginPollUseCase() }
    }
    var loginUrlUseCase: Factory<any LoginUrlUseCaseProtocol> {
        self { LoginUrlUseCase() }
    }
    var managedConfigurationUseCase: Factory<any ManagedConfigurationUseCaseProtocol> {
        self { ManagedConfigurationUseCase() }
            .cached
    }
    var onDemandWordlistUseCase: Factory<any OnDemandWordlistUseCaseProtocol> {
        self { OnDemandWordlistUseCase() }
            .cached
    }
    @available(iOS 17, *) var openProviderSettingsUseCase: Factory<any OpenProviderSettingsUseCaseProtocol> {
        self { OpenProviderSettingsUseCase() }
    }
    var preferredUsernameUseCase: Factory<any PreferredUsernameUseCaseProtocol> {
        self { PreferredUsernameUseCase() }
            .cached
    }
    var randomWordUseCase: Factory<any RandomWordUseCaseProtocol> {
        self { RandomWordUseCase() }
    }
    var wordlistLocaleUseCase: Factory<any WordlistLocaleUseCaseProtocol> {
        self { WordlistLocaleUseCase() }
            .cached
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
    var onDemandResourcesPropertyListDataSource: Factory<any OnDemandResourcesPropertyListDataSourceProtocol> {
        self { OnDemandResourcesPropertyListDataSource() }
            .cached
    }
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
    var windowSizeDataSource: Factory<any WindowSizeDataSourceProtocol> {
        self { WindowSizeDataSource() }
            .cached
    }
    var windowSizeRepository: Factory<any WindowSizeRepositoryProtocol> {
        self { WindowSizeRepository() }
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
    @available(iOS 17, *) var credentialProviderSettingsHelperType: Factory<any CredentialProviderSettingsHelping.Type> {
        self { ASSettingsHelper.self }
    }
    var nonPersistentWebDataStore: Factory<any WebDataStore> {
        self { WKWebsiteDataStore.nonPersistent() }
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
    var randomNumberGenerator: Factory<any RandomNumberGenerator> {
        self { RandomBytes.Generator() }
    }
    var systemNotifications: Factory <any Notifications> {
        self { NotificationCenter.default }
    }
    var transactionType: Factory<any Transaction.Type> {
        self { StoreKit.Transaction.self }
    }
    var videoCapturer: Factory<(any VideoCapturing)?> {
        self {
            if #available(iOS 17.0, *) {
                AVCaptureDevice.userPreferredCamera
            } else {
                AVCaptureDevice.default(for: .video)
            }
        }
    }
    
    // MARK: Miscellaneous
    var configurationType: Factory<any Configurating.Type> {
        self { Configuration.self }
    }
    var currentDate: Factory<Date> {
        self { .init() }
    }
    var mainScheduler: Factory<AnySchedulerOf<DispatchQueue>> {
        self { DispatchQueue.main.eraseToAnyScheduler() }
    }
    var userInitiatedScheduler: Factory<AnySchedulerOf<DispatchQueue>> {
        self { DispatchQueue(qos: .userInitiated).eraseToAnyScheduler() }
    }
    
    // TODO: remove
    var entriesController: Factory<EntriesController> {
        self { .init() }
            .cached
    }
    
}
