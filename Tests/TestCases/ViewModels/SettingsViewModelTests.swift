import XCTest
import Nimble
import Factory
@testable import Passwords


final class SettingsViewModelTests: XCTestCase {
    
    @MockInjected(\.sessionService) private var sessionServiceMock: SessionServiceMock
    @MockInjected(\.settingsService) private var settingsServiceMock: SettingsServiceMock
    @MockInjected(\.purchaseService) private var purchaseServiceMock: PurchaseServiceMock
    @MockInjected(\.logger) private var loggerMock: LoggerMock
    
    override func setUp() {
        super.setUp()
        
        PollingDefaults.timeout = .milliseconds(300)
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
        ConfigurationMock.buildNumberString = "0"
        ConfigurationMock.shortVersionString = "0.0.0"
        ConfigurationMock.isDebug = true
        ConfigurationMock.isTestFlight = false
    }
    
    func testInit_thenSetsInitialState() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        expect(settingsViewModel[\.username]).to(beNil())
        expect(settingsViewModel[\.server]).to(beNil())
        expect(settingsViewModel[\.showLogoutAlert]).to(beFalse())
        expect(settingsViewModel[\.isOfflineStorageEnabled]).to(beFalse())
        expect(settingsViewModel[\.isAutomaticPasswordGenerationEnabled]).to(beFalse())
        expect(settingsViewModel[\.isUniversalClipboardEnabled]).to(beFalse())
        expect(settingsViewModel[\.canPurchaseTip]).to(beFalse())
        expect(settingsViewModel[\.tipProducts]).to(beNil())
        expect(settingsViewModel[\.isTipTransactionRunning]).to(beFalse())
        expect(settingsViewModel[\.isTestFlight]).to(beFalse())
        expect(settingsViewModel[\.betaUrl]).to(equal(.init(string: "https://testflight.apple.com/join/iuljLJ4u")!))
        expect(settingsViewModel[\.isLogAvailable]).to(beFalse())
        expect(settingsViewModel[\.versionName]).to(equal("0.0.0 (Debug, Build 0)"))
        expect(settingsViewModel[\.sourceCodeUrl]).to(equal(.init(string: "https://github.com/johannes-schliephake/nextcloud-passwords-ios")!))
    }
    
    func testInit_givenIsDebugIsFalseAndIsTestFlightIsFalse_thenSetsVersionName() {
        ConfigurationMock.isDebug = false
        ConfigurationMock.isTestFlight = false
        
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        expect(settingsViewModel[\.versionName]).to(equal("0.0.0"))
    }
    
    func testInit_givenIsDebugIsTrueAndIsTestFlightIsFalse_thenSetsVersionName() {
        ConfigurationMock.isDebug = true
        ConfigurationMock.isTestFlight = false
        
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        expect(settingsViewModel[\.versionName]).to(equal("0.0.0 (Debug, Build 0)"))
    }
    
    func testInit_givenIsDebugIsFalseAndIsTestFlightIsTrue_thenSetsVersionName() {
        ConfigurationMock.isDebug = false
        ConfigurationMock.isTestFlight = true
        
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        expect(settingsViewModel[\.versionName]).to(equal("0.0.0 (TestFlight, Build 0)"))
    }
    
    func testInit_whenSessionServiceEmittingUsername_thenSetsUsername() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let usernameMock = String.random()
        
        sessionServiceMock._username.send(usernameMock)
        
        expect(settingsViewModel[\.username]).to(equal(usernameMock))
    }
    
    func testInit_whenSessionServiceEmittingServer_thenSetsServer() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let serverMock = String.random()
        
        sessionServiceMock._server.send(serverMock)
        
        expect(settingsViewModel[\.server]).to(equal(serverMock))
    }
    
    func testInit_whenSettingsServiceEmittingIsOfflineStorageEnabled_thenSetsIsOfflineStorageEnabled() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let isOfflineStorageEnabledMock = Bool.random()
        
        settingsServiceMock._isOfflineStorageEnabledPublisher.send(isOfflineStorageEnabledMock)
        
        expect(settingsViewModel[\.isOfflineStorageEnabled]).to(equal(isOfflineStorageEnabledMock))
    }
    
    func testInit_whenSettingsServiceEmittingIsAutomaticPasswordGenerationEnabled_thenSetsIsAutomaticPasswordGenerationEnabled() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let isAutomaticPasswordGenerationEnabledMock = Bool.random()
        
        settingsServiceMock._isAutomaticPasswordGenerationEnabledPublisher.send(isAutomaticPasswordGenerationEnabledMock)
        
        expect(settingsViewModel[\.isAutomaticPasswordGenerationEnabled]).to(equal(isAutomaticPasswordGenerationEnabledMock))
    }
    
    func testInit_whenSettingsServiceEmittingIsUniversalClipboardEnabled_thenSetsIsUniversalClipboardEnabled() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let isUniversalClipboardEnabledMock = Bool.random()
        
        settingsServiceMock._isUniversalClipboardEnabledPublisher.send(isUniversalClipboardEnabledMock)
        
        expect(settingsViewModel[\.isUniversalClipboardEnabled]).to(equal(isUniversalClipboardEnabledMock))
    }
    
    func testInit_whenPurchaseServiceEmittingProducts_thenSetsTipProducts() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let productsMock = [ProductMock(), ProductMock()]
        
        purchaseServiceMock._products.send(productsMock)
        
        expect(settingsViewModel[\.tipProducts]?.compactMap { $0 as? ProductMock }).toEventually(equal(productsMock))
    }
    
    func testInit_whenPurchaseServiceEmittingProductsFromBackgroundThread_thenSetsTipProductsFromMainThread() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let productsMock = [ProductMock(), ProductMock()]
        
        expect(settingsViewModel[\.$tipProducts].dropFirst().compactMap { $0 as? [ProductMock] }).to(emit(productsMock, onMainThread: true, when: { self.purchaseServiceMock._products.send(productsMock) }, from: .init()))
    }
    
    func testInit_whenPurchaseServiceEmittingTransactionStatePurchasing_thenSetsIsTipTransactionRunningToTrue() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        purchaseServiceMock._transactionState.send(.purchasing)
        
        expect(settingsViewModel[\.isTipTransactionRunning]).toEventually(beTrue())
    }
    
    func testInit_whenPurchaseServiceEmittingTransactionStatePending_thenSetsIsTipTransactionRunningToFalse() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        purchaseServiceMock._transactionState.send(.pending)
        
        expect(settingsViewModel[\.isTipTransactionRunning]).toAlways(beFalse())
    }
    
    func testInit_whenPurchaseServiceEmittingTransactionStatePurchased_thenSetsIsTipTransactionRunningToFalse() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        purchaseServiceMock._transactionState.send(.purchased)
        
        expect(settingsViewModel[\.isTipTransactionRunning]).toAlways(beFalse())
    }
    
    func testInit_whenPurchaseServiceEmittingTransactionStateFailed_thenSetsIsTipTransactionRunningToFalse() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        purchaseServiceMock._transactionState.send(.failed)
        
        expect(settingsViewModel[\.isTipTransactionRunning]).toAlways(beFalse())
    }
    
    func testInit_whenPurchaseServiceEmittingTransactionStateNil_thenSetsIsTipTransactionRunningToFalse() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        purchaseServiceMock._transactionState.send(nil)
        
        expect(settingsViewModel[\.isTipTransactionRunning]).toAlways(beFalse())
    }
    
    func testInit_whenPurchaseServiceEmittingTransactionStateFromBackgroundThread_thenSetsIsTipTransactionRunningFromMainThread() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        expect(settingsViewModel[\.$isTipTransactionRunning].dropFirst()).to(emit(true, onMainThread: true, when: { self.purchaseServiceMock._transactionState.send(.purchasing) }, from: .init()))
    }
    
    func testInit_whenPurchaseServiceNotEmittingProductsAndEmittingTransactionStatePurchasing_thenSetsCanPurchaseTipToFalse() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        purchaseServiceMock._transactionState.send(.purchasing)
        
        expect(settingsViewModel[\.canPurchaseTip]).toAlways(beFalse())
    }
    
    func testInit_whenPurchaseServiceEmittingEmptyProductsAndTransactionStatePurchasing_thenSetsCanPurchaseTipToFalse() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        purchaseServiceMock._products.send([])
        purchaseServiceMock._transactionState.send(.purchasing)
        
        expect(settingsViewModel[\.canPurchaseTip]).toAlways(beFalse())
    }
    
    func testInit_whenPurchaseServiceEmittingProductsAndTransactionStatePurchasing_thenSetsCanPurchaseTipToFalse() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        purchaseServiceMock._products.send([ProductMock()])
        purchaseServiceMock._transactionState.send(.purchasing)
        
        expect(settingsViewModel[\.canPurchaseTip]).toAlways(beFalse())
    }
    
    func testInit_whenPurchaseServiceNotEmittingProductsAndEmittingTransactionStateNotPurchasing_thenSetsCanPurchaseTipToFalse() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let transactionStateMock = (Array(TransactionState.allCases.dropFirst()) + [nil]).randomElement() ?? nil
        
        purchaseServiceMock._transactionState.send(transactionStateMock)
        
        expect(settingsViewModel[\.canPurchaseTip]).toAlways(beFalse())
    }
    
    func testInit_whenPurchaseServiceEmittingEmptyProductsAndTransactionStateNotPurchasing_thenSetsCanPurchaseTipToFalse() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let transactionStateMock = (Array(TransactionState.allCases.dropFirst()) + [nil]).randomElement() ?? nil
        
        purchaseServiceMock._products.send([])
        purchaseServiceMock._transactionState.send(transactionStateMock)
        
        expect(settingsViewModel[\.canPurchaseTip]).toAlways(beFalse())
    }
    
    func testInit_whenPurchaseServiceEmittingProductsAndTransactionStateNotPurchasing_thenSetsCanPurchaseTipToTrue() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let transactionStateMock = (Array(TransactionState.allCases.dropFirst()) + [nil]).randomElement() ?? nil
        
        purchaseServiceMock._products.send([ProductMock()])
        purchaseServiceMock._transactionState.send(transactionStateMock)
        
        expect(settingsViewModel[\.canPurchaseTip]).toEventually(beTrue())
    }
    
    func testInit_whenPurchaseServiceEmittingProductsAndTransactionStateFromBackgroundThread_thenSetsCanPurchaseTipFromMainThread() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        expect(settingsViewModel[\.$canPurchaseTip].dropFirst(2)).to(emit(true, onMainThread: true, when: {
            self.purchaseServiceMock._products.send([ProductMock()])
            self.purchaseServiceMock._transactionState.send(nil)
        }, from: .init()))
    }
    
    func testInit_whenLoggerEmittingIsAvailable_thenSetsIsLogAvailable() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let isAvailableMock = Bool.random()
        
        loggerMock._isAvailablePublisher.send(isAvailableMock)
        
        expect(settingsViewModel[\.isLogAvailable]).toEventually(equal(isAvailableMock))
    }
    
    func testInit_whenLoggerEmittingIsAvailableFromBackgroundThread_thenSetsIsLogAvailableFromMainThread() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let isAvailableMock = Bool.random()
        
        expect(settingsViewModel[\.$isLogAvailable].dropFirst()).to(emit(isAvailableMock, onMainThread: true, when: { self.loggerMock._isAvailablePublisher.send(isAvailableMock) }, from: .init()))
    }
    
    func testCallAsFunction_whenCallingLogout_thenSetsShowLogoutAlertToTrue() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        settingsViewModel(.logout)
        
        expect(settingsViewModel[\.showLogoutAlert]).to(beTrue())
    }
    
    func testCallAsFunction_whenCallingConfirmLogout_thenCallsSessionService() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        settingsViewModel(.confirmLogout)
        
        expect(self.sessionServiceMock).to(beCalled(.once, on: "logout()"))
    }
    
    func testCallAsFunction_whenCallingConfirmLogout_thenShouldDismissEmits() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        expect(settingsViewModel[\.shouldDismiss]).to(emit(when: { settingsViewModel(.confirmLogout) }))
    }
    
    func testCallAsFunction_whenCallingSetIsOfflineStorageEnabled_thenCallsSettingsService() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let isOfflineStorageEnabledMock = Bool.random()
        
        settingsViewModel(.setIsOfflineStorageEnabled(isOfflineStorageEnabledMock))
        
        expect(self.settingsServiceMock).to(beAccessed(.once, on: "isOfflineStorageEnabled"))
        expect(self.settingsServiceMock._isOfflineStorageEnabled).to(equal(isOfflineStorageEnabledMock))
    }
    
    func testCallAsFunction_whenCallingSetIsAutomaticPasswordGenerationEnabled_thenCallsSettingsService() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let isAutomaticPasswordGenerationEnabledMock = Bool.random()
        
        settingsViewModel(.setIsAutomaticPasswordGenerationEnabled(isAutomaticPasswordGenerationEnabledMock))
        
        expect(self.settingsServiceMock).to(beAccessed(.once, on: "isAutomaticPasswordGenerationEnabled"))
        expect(self.settingsServiceMock._isAutomaticPasswordGenerationEnabled).to(equal(isAutomaticPasswordGenerationEnabledMock))
    }
    
    func testCallAsFunction_whenCallingSetIsUniversalClipboardEnabled_thenCallsSettingsService() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let isUniversalClipboardEnabledMock = Bool.random()
        
        settingsViewModel(.setIsUniversalClipboardEnabled(isUniversalClipboardEnabledMock))
        
        expect(self.settingsServiceMock).to(beAccessed(.once, on: "isUniversalClipboardEnabled"))
        expect(self.settingsServiceMock._isUniversalClipboardEnabled).to(equal(isUniversalClipboardEnabledMock))
    }
    
    func testCallAsFunction_whenCallingTip_thenCallsPurchaseService() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        let productMock = ProductMock()
        
        settingsViewModel(.tip(productMock))
        
        expect(self.purchaseServiceMock).to(beCalled(.once, on: "purchase(product:)", withParameter: productMock))
    }
    
    func testCallAsFunction_whenCallingDone_thenShouldDismissEmits() {
        let settingsViewModel: any SettingsViewModelProtocol = SettingsViewModel()
        
        expect(settingsViewModel[\.shouldDismiss]).to(emit(when: { settingsViewModel(.done) }))
    }

}
