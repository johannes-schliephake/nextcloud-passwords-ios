import XCTest
import Nimble
import Factory
@testable import Passwords


final class ServerSetupViewModelTests: XCTestCase {
    
    private let loginUrlMock = LoginURL(string: "https://example.com")
    private let challengeMock = LoginFlowChallenge(login: .random(), poll: .init(token: .random(), endpoint: .random()))
    
    @LazyInjected(\.mainSchedulerMock) private var mainSchedulerMock
    @LazyInjected(\.userInitiatedSchedulerMock) private var userInitiatedSchedulerMock
    @MockInjected(\.loginUrlUseCase) private var loginUrlUseCaseMock: LoginUrlUseCaseMock
    @MockInjected(\.managedConfigurationUseCase) private var managedConfigurationUseCaseMock: ManagedConfigurationUseCaseMock
    @MockInjected(\.initiateLoginUseCase) private var initiateLoginUseCaseMock: InitiateLoginUseCaseMock
    @MockInjected(\.authenticationUseCase) private var authenticationUseCaseMock: AuthenticationUseCaseMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        expect(serverSetupViewModel[\.serverAddress]).to(equal("https://"))
        expect(serverSetupViewModel[\.isServerAddressManaged]).to(beFalse())
        expect(serverSetupViewModel[\.showManagedServerAddressErrorAlert]).to(beFalse())
        expect(serverSetupViewModel[\.isValidating]).to(beFalse())
        expect(serverSetupViewModel[\.challengeAvailable]).to(beFalse())
        expect(serverSetupViewModel[\.focusedField]).to(equal(.serverAddress))
    }
    
    func testInit_thenAccessesManagedConfigurationUseCase() {
        _ = ServerSetupViewModel()
        
        expect(self.managedConfigurationUseCaseMock).to(beAccessed(.once, on: "$serverUrl"))
    }
    
    func testInit_thenAccessesLoginUrlUseCase() {
        _ = ServerSetupViewModel()
        
        expect(self.loginUrlUseCaseMock).to(beAccessed(.once, on: "$loginUrl"))
    }
    
    func testInit_whenManagedConfigurationUseCaseEmittingNil_thenSetsServerAddressToFallback() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(nil))
        
        expect(serverSetupViewModel[\.serverAddress]).to(equal("https://"))
        expect(serverSetupViewModel[\.isServerAddressManaged]).to(beFalse())
    }
    
    func testInit_whenManagedConfigurationUseCaseEmittingServerUrl_thenSetsServerAddress() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        let serverUrlMock = String.random()
        
        managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(serverUrlMock))
        
        expect(serverSetupViewModel[\.serverAddress]).to(equal(serverUrlMock))
        expect(serverSetupViewModel[\.isServerAddressManaged]).to(beTrue())
    }
    
    func testInit_whenSettingServerAddress_thenCallsInitiateLoginUseCase() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        serverSetupViewModel[\.serverAddress] = .random()
        
        expect(self.initiateLoginUseCaseMock).to(beCalled(.once, on: "cancel"))
    }
    
    func testInit_whenSettingServerAddress_thenSetsIsValidatingToFalse() throws {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        try require(serverSetupViewModel[\.isValidating]).to(beTrue())
        
        serverSetupViewModel[\.serverAddress] = .random()
        
        expect(serverSetupViewModel[\.isValidating]).to(beFalse())
    }
    
    func testInit_whenSettingServerAddress_thenSetsChallengeAvailableToFalse() throws {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        initiateLoginUseCaseMock.mockState(\.challenge, value: .success(challengeMock))
        mainSchedulerMock.advance()
        try require(serverSetupViewModel[\.challengeAvailable]).toNot(beFalse())
        
        serverSetupViewModel[\.serverAddress] = .random()
        
        expect(serverSetupViewModel[\.challengeAvailable]).to(beFalse())
    }
    
    func testInit_whenSettingServerAddress_thenCallsLoginUrlUseCase() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        let serverAddressMock = String.random()
        
        serverSetupViewModel[\.serverAddress] = serverAddressMock
        
        expect(self.loginUrlUseCaseMock).to(beCalled(.once, on: "setString", withParameter: serverAddressMock))
    }
    
    func testInit_whenLoginUrlUseCaseEmittingLoginUrl_thenSetsIsValidatingToTrue() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        
        expect(serverSetupViewModel[\.isValidating]).to(beTrue())
    }
    
    func testInit_whenLoginUrlUseCaseEmittingNil_thenSetsIsValidatingToFalse() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(nil))
        
        expect(serverSetupViewModel[\.isValidating]).to(beFalse())
    }
    
    func testInit_givenNonManagedServerAddress_whenLoginUrlUseCaseEmittingNil_thenSetsShowManagedServerAddressErrorAlertToFalse() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(nil))
        
        expect(serverSetupViewModel[\.showManagedServerAddressErrorAlert]).to(beFalse())
    }
    
    func testInit_givenManagedServerAddress_whenLoginUrlUseCaseEmittingNil_thenSetsShowManagedServerAddressErrorAlertToTrue() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random()))
        
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(nil))
        
        expect(serverSetupViewModel[\.showManagedServerAddressErrorAlert]).to(beTrue())
    }
    
    func testInit_whenLoginUrlUseCaseEmittingLoginUrl_thenCallsInitiateLoginUseCase() {
        withExtendedLifetime(ServerSetupViewModel()) {
            loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
            userInitiatedSchedulerMock.run()
            
            expect(self.initiateLoginUseCaseMock).to(beCalled(.once, on: "setLoginUrl", withParameter: loginUrlMock))
        }
    }
    
    func testInit_whenLoginUrlUseCaseEmittingNil_thenDoesntCallInitiateLoginUseCase() {
        withExtendedLifetime(ServerSetupViewModel()) {
            loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(nil))
            userInitiatedSchedulerMock.run()
            
            expect(self.initiateLoginUseCaseMock).toNot(beCalled())
        }
    }
    
    func testInit_whenLoginUrlUseCaseEmittingLoginUrl_thenDebouncesCallToInitiateLoginUseCase() {
        withExtendedLifetime(ServerSetupViewModel()) {
            loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
            
            expect(self.initiateLoginUseCaseMock).toNot(beCalled())
            
            userInitiatedSchedulerMock.advance(by: 1.4)
            expect(self.initiateLoginUseCaseMock).toNot(beCalled())
            
            userInitiatedSchedulerMock.advance(by: 0.2)
            expect(self.initiateLoginUseCaseMock).to(beCalled(.once, on: "setLoginUrl", withParameter: loginUrlMock))
        }
    }
    
    func testInit_whenLoginUrlUseCaseEmittingMultipleTimes_thenDebouncesCallToInitiateLoginUseCase() {
        withExtendedLifetime(ServerSetupViewModel()) {
            loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
            
            expect(self.initiateLoginUseCaseMock).toNot(beCalled())
            
            userInitiatedSchedulerMock.advance(by: 1.4)
            loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(nil))
            expect(self.initiateLoginUseCaseMock).toNot(beCalled())
            
            userInitiatedSchedulerMock.advance(by: 1.0)
            loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
            expect(self.initiateLoginUseCaseMock).toNot(beCalled())
            
            userInitiatedSchedulerMock.advance(by: 1.4)
            expect(self.initiateLoginUseCaseMock).toNot(beCalled())
            
            userInitiatedSchedulerMock.advance(by: 0.2)
            expect(self.initiateLoginUseCaseMock).to(beCalled(.once, on: "setLoginUrl", withParameter: loginUrlMock))
        }
    }
    
    func testInit_whenInitiateLoginUseCaseEmittingChallenge_thenSetsIsValidatingToFalseOnMainScheduler() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        expect(serverSetupViewModel[\.$isValidating].dropFirst())
            .toNot(emit(when: { self.initiateLoginUseCaseMock.mockState(\.challenge, value: .success(self.challengeMock)) }))
            .to(emit(false, when: { self.mainSchedulerMock.advance() }))
    }
    
    func testInit_whenInitiateLoginUseCaseEmittingChallenge_thenSetsChallengeAvailableOnMainScheduler() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        expect(serverSetupViewModel[\.$challengeAvailable].dropFirst())
            .toNot(emit(when: { self.initiateLoginUseCaseMock.mockState(\.challenge, value: .success(self.challengeMock)) }))
            .to(emit(true, when: { self.mainSchedulerMock.advance() }))
    }
    
    func testInit_givenNonManagedServerAddress_whenInitiateLoginUseCaseFailing_thenSetsShowManagedServerAddressErrorAlertToFalse() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        initiateLoginUseCaseMock.mockState(\.challenge, value: .failure(ErrorMock.standard))
        mainSchedulerMock.advance()
        
        expect(serverSetupViewModel[\.showManagedServerAddressErrorAlert]).to(beFalse())
    }
    
    func testInit_givenManagedServerAddress_whenInitiateLoginUseCaseFailing_thenSetsShowManagedServerAddressErrorAlertToTrue() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random()))
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        initiateLoginUseCaseMock.mockState(\.challenge, value: .failure(ErrorMock.standard))
        mainSchedulerMock.advance()
        
        expect(serverSetupViewModel[\.showManagedServerAddressErrorAlert]).to(beTrue())
    }
    
    func testInit_whenInitiateLoginUseCaseFailing_thenSetsShowManagedServerAddressErrorAlertOnMainScheduler() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random()))
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        expect(serverSetupViewModel[\.$showManagedServerAddressErrorAlert].dropFirst())
            .toNot(emit(when: { self.initiateLoginUseCaseMock.mockState(\.challenge, value: .failure(ErrorMock.standard)) }))
            .to(emit(when: { self.mainSchedulerMock.advance() }))
    }
    
    func testInit_whenInitiateLoginUseCaseFailing_thenSetsChallengeAvailableToFalse() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        initiateLoginUseCaseMock.mockState(\.challenge, value: .failure(ErrorMock.standard))
        mainSchedulerMock.advance()
        
        expect(serverSetupViewModel[\.challengeAvailable]).to(beFalse())
    }
    
    func testInit_givenIsServerAddressManagedIsTrue_whenInitiateLoginUseCaseEmittingChallenge_thenCallsAuthenticationUseCase() {
        withExtendedLifetime(ServerSetupViewModel()) {
            managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random()))
            loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
            userInitiatedSchedulerMock.run()
            
            initiateLoginUseCaseMock.mockState(\.challenge, value: .success(challengeMock))
            mainSchedulerMock.advance()
            
            expect(self.authenticationUseCaseMock).to(beCalled(.once, on: "setChallenge", withParameter: challengeMock))
        }
    }
    
    func testInit_givenIsServerAddressManagedIsFalse_whenInitiateLoginUseCaseEmittingChallenge_thenDoesntCallAuthenticationUseCase() {
        withExtendedLifetime(ServerSetupViewModel()) {
            loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
            userInitiatedSchedulerMock.run()
            
            initiateLoginUseCaseMock.mockState(\.challenge, value: .success(challengeMock))
            mainSchedulerMock.advance()
            
            expect(self.authenticationUseCaseMock).toNot(beCalled())
        }
    }
    
    func testInit_givenIsServerAddressManagedIsTrue_thenDoesntCallAuthenticationUseCase() {
        withExtendedLifetime(ServerSetupViewModel()) {
            managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random()))
            
            expect(self.authenticationUseCaseMock).toNot(beCalled())
        }
    }
    
    func testInit_givenIsServerAddressManagedIsFalse_thenDoesntCallAuthenticationUseCase() {
        _ = ServerSetupViewModel()
        
        expect(self.authenticationUseCaseMock).toNot(beCalled())
    }
    
    func testInit_givenIsServerAddressManagedIsTrue_whenAuthenticationUseCaseSetsLatestAttemptFailedToTrue_thenShouldDismissEmits() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random()))
        
        expect(serverSetupViewModel[\.shouldDismiss]).to(emit(when: { self.authenticationUseCaseMock.mockState(\.latestAttemptFailed, value: .success(true)) }))
    }
    
    func testInit_givenIsServerAddressManagedIsTrue_whenAuthenticationUseCaseSetsLatestAttemptFailedToFalse_thenShouldDismissDoesntEmit() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random()))
        
        expect(serverSetupViewModel[\.shouldDismiss]).toNot(emit(when: { self.authenticationUseCaseMock.mockState(\.latestAttemptFailed, value: .success(false)) }))
    }
    
    func testInit_givenIsServerAddressManagedIsFalse_whenAuthenticationUseCaseSetsLatestAttemptFailedToTrue_thenShouldDismissDoesntEmit() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        expect(serverSetupViewModel[\.shouldDismiss]).toNot(emit(when: { self.authenticationUseCaseMock.mockState(\.latestAttemptFailed, value: .success(true)) }))
    }
    
    func testInit_givenIsServerAddressManagedIsFalse_whenAuthenticationUseCaseSetsLatestAttemptFailedToFalse_thenShouldDismissDoesntEmit() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        expect(serverSetupViewModel[\.shouldDismiss]).toNot(emit(when: { self.authenticationUseCaseMock.mockState(\.latestAttemptFailed, value: .success(false)) }))
    }
    
    func testInit_whenManagedConfigurationUseCaseEmittingServerUrl_thenShouldDismissDoesntEmit() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        expect(serverSetupViewModel[\.shouldDismiss]).toNot(emit(when: { self.managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random())) }))
    }
    
    func testCallAsFunction_givenChallengeAvailableIsTrue_whenCallingConnect_thenCallsAuthenticationUseCase() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        initiateLoginUseCaseMock.mockState(\.challenge, value: .success(challengeMock))
        mainSchedulerMock.advance()
        
        serverSetupViewModel(.connect)
        
        expect(self.authenticationUseCaseMock).to(beCalled(.once, on: "setChallenge", withParameter: challengeMock))
    }
    
    func testCallAsFunction_givenChallengeAvailableIsFalse_whenCallingConnect_thenDoesntCallAuthenticationUseCase() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        serverSetupViewModel(.connect)
        
        expect(self.authenticationUseCaseMock).toNot(beCalled())
    }
    
    func testCallAsFunction_whenCallingCancel_thenShouldDismissEmits() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        expect(serverSetupViewModel[\.shouldDismiss]).to(emit(when: { serverSetupViewModel(.cancel) }))
    }
    
}
