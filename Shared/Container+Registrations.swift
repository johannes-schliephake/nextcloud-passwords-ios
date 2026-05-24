import FactoryKit
import CoreImage
import StoreKit
import CombineSchedulers
import WebKit
import AuthenticationServices
import Sodium
import Foundation
import FoundationModels


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
    var authenticationUseCase: Factory<any AuthenticationUseCaseProtocol> {
        self { AuthenticationUseCase() }
            .cached
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
    @available(iOS 17, *) var openProviderSettingsUseCase: Factory<any OpenProviderSettingsUseCaseProtocol> {
        self { OpenProviderSettingsUseCase() }
    }
    var preferredUsernameUseCase: Factory<any PreferredUsernameUseCaseProtocol> {
        self { PreferredUsernameUseCase() }
            .cached
    }
    var prepareWordlistUseCase: Factory<any PrepareWordlistUseCaseProtocol> {
        self { PrepareWordlistUseCase() }
            .cached
    }
    var randomWordUseCase: Factory<any RandomWordUseCaseProtocol> {
        self { RandomWordUseCase() }
    }
    var windowSizeUseCase: Factory<any WindowSizeUseCaseProtocol> {
        self { WindowSizeUseCase() }
            .cached
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
    
    // MARK: Repositories
    var onDemandResourcesPropertyListDataSource: Factory<any OnDemandResourcesPropertyListDataSourceProtocol> {
        self { OnDemandResourcesPropertyListDataSource() }
            .cached
    }
    var onDemandResourcesRepository: Factory<any OnDemandResourcesRepositoryProtocol> {
        self { OnDemandResourcesRepository() }
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
    @available(iOS 26, *) var urlLabelSuggestionLanguageModelDataSource: Factory<any UrlLabelSuggestionLanguageModelDataSourceProtocol> { // swiftlint:disable:this identifier_name
        self { UrlLabelSuggestionLanguageModelDataSource() }
    }
    @available(iOS 26, *) var urlLabelSuggestionRepository: Factory<any UrlLabelSuggestionRepositoryProtocol> {
        self { UrlLabelSuggestionRepository() }
            .cached
    }
    var windowDataSource: Factory<any WindowDataSourceProtocol> {
        self { WindowDataSource() }
            .cached
    }
    var windowRepository: Factory<any WindowRepositoryProtocol> {
        self { WindowRepository() }
            .cached
    }
    var wordlistDataSource: Factory<any WordlistDataSourceProtocol> {
        self { WordlistDataSource() }
    }
    var wordlistPreparationDataSource: Factory<any WordlistPreparationDataSourceProtocol> {
        self { WordlistPreparationDataSource() }
            .cached
    }
    var wordlistRepository: Factory<any WordlistRepositoryProtocol> {
        self { WordlistRepository() }
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
    var bundleResourceRequestType: Factory<any BundleResourceRequesting.Type> {
        self { NSBundleResourceRequest.self }
    }
    @available(iOS 17, *) var credentialProviderSettingsHelperType: Factory<any CredentialProviderSettingsHelping.Type> {
        self { ASSettingsHelper.self }
    }
    @available(iOS 26, *) var defaultLanguageModelType: Factory<any DefaultLanguageModel.Type> {
        self { LanguageModelSession.self }
    }
    var fileHandleType: Factory<any FileHandling.Type> {
        self { FileHandle.self }
    }
    var fileManager: Factory<any FileManaging> {
        self { FileManager.default }
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
    var webAuthenticationSessionType: Factory<any WebAuthenticationSession.Type> {
        self { WrappedASWebAuthenticationSession.self }
    }
    
    // MARK: Miscellaneous
    var configurationType: Factory<any Configurating.Type> {
        self { Configuration.self }
    }
    var cryptoSHA256Type: Factory<any CryptoSHA256Protocol.Type> {
        self { Crypto.SHA256.self }
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
    @MainActor var application: Factory<UIApplication?> {
        self {
            guard !UIApplication.isExtension,
                  UIApplication.responds(to: NSSelectorFromString("sharedApplication")) else {
                return nil
            }
            return UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() as? UIApplication
        }
        .cached
    }
    var urlSession: Factory<URLSession> {
        self {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = ["User-Agent": Configuration.clientName]
            return URLSession(configuration: configuration, delegate: dependency(\.authenticationChallengeController), delegateQueue: nil)
        }
        .cached
    }
    var rootViewController: Factory<UIViewController?> {
        self { nil }
            .cached
    }
    var entriesController: Factory<EntriesController> {
        self {
#if DEBUG
            Configuration.isTestEnvironment ? .mock : .init()
#else
            .init()
#endif
        }
        .cached
    }
    var authenticationChallengeController: Factory<AuthenticationChallengeController> {
        self { .init() }
            .cached
    }
    var autoFillController: Factory<AutoFillController> {
        self {
#if DEBUG
            Configuration.isTestEnvironment ? .mock : .init()
#else
            .init()
#endif
        }
        .cached
    }
    var sessionController: Factory<SessionController> {
        self {
#if DEBUG
            Configuration.isTestEnvironment ? .mock : .init()
#else
            .init()
#endif
        }
        .cached
    }
    var settingsController: Factory<SettingsController> {
        self {
#if DEBUG
            Configuration.isTestEnvironment ? .mock : .init()
#else
            .init()
#endif
        }
        .cached
    }
    var coreData: Factory<CoreData> {
        self { .init() }
            .cached
    }
    var keychain: Factory<Keychain> {
        self { .init() }
            .cached
    }
    var sodium: Factory<Sodium> {
        self { .init() }
            .cached
    }
    var biometricAuthenticationController: Factory<BiometricAuthenticationController> {
        self {
#if DEBUG
            Configuration.isTestEnvironment ? .mock : .init()
#else
            .init()
#endif
        }
        .cached
    }
    
}
