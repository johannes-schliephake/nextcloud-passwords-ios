import XCTest
import Nimble
import Factory
@testable import Passwords


final class ServerSetupViewModelTests: XCTestCase {
    
    private let loginUrlMock = LoginURL(string: "https://example.com")
    private let challengeMock = LoginFlowChallenge(login: .random(), poll: .init(token: .random(), endpoint: .random()))
    
    @LazyInjected(\.userInitiatedSchedulerMock) private var userInitiatedSchedulerMock
    @MockInjected(\.loginUrlUseCase) private var loginUrlUseCaseMock: LoginUrlUseCaseMock
    @MockInjected(\.managedConfigurationUseCase) private var managedConfigurationUseCaseMock: ManagedConfigurationUseCaseMock
    @MockInjected(\.initiateLoginUseCase) private var initiateLoginUseCaseMock: InitiateLoginUseCaseMock
    
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
        expect(serverSetupViewModel[\.challenge]).to(beNil())
        expect(serverSetupViewModel[\.challengeAvailable]).to(beFalse())
        expect(serverSetupViewModel[\.showLoginFlowPage]).to(beFalse())
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
    
    func testInit_whenSettingServerAddress_thenCallsInitiateLoginUseCase() throws {
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
    
    func testInit_whenSettingServerAddress_thenClearsChallenge() throws {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        initiateLoginUseCaseMock.mockState(\.challenge, value: .success(challengeMock))
        try require(serverSetupViewModel[\.challenge]).toEventuallyNot(beNil())
        try require(serverSetupViewModel[\.challengeAvailable]).toEventuallyNot(beFalse())
        
        serverSetupViewModel[\.serverAddress] = .random()
        
        expect(serverSetupViewModel[\.challenge]).to(beNil())
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
    
    func testInit_whenInitiateLoginUseCaseEmittingChallenge_thenSetsIsValidatingToFalse() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        initiateLoginUseCaseMock.mockState(\.challenge, value: .success(challengeMock))
        
        expect(serverSetupViewModel[\.isValidating]).toEventually(beFalse())
    }
    
    func testInit_whenInitiateLoginUseCaseEmittingChallenge_thenSetsChallenge() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        initiateLoginUseCaseMock.mockState(\.challenge, value: .success(challengeMock))
        
        expect(serverSetupViewModel[\.challenge]).toEventually(equal(challengeMock))
        expect(serverSetupViewModel[\.challengeAvailable]).toEventually(beTrue())
    }
    
    func testInit_whenInitiateLoginUseCaseEmittingChallengeFromBackgroundThread_thenSetsIsValidatingFromMainThread() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        expect(serverSetupViewModel[\.$isValidating].dropFirst()).to(emit(onMainThread: true, when: { self.initiateLoginUseCaseMock.mockState(\.challenge, value: .success(self.challengeMock)) }, from: .init()))
    }
    
    func testInit_whenInitiateLoginUseCaseEmittingChallengeFromBackgroundThread_thenSetsChallengeFromMainThread() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        expect(serverSetupViewModel[\.$challenge].dropFirst()).to(emit(onMainThread: true, when: { self.initiateLoginUseCaseMock.mockState(\.challenge, value: .success(self.challengeMock)) }, from: .init()))
    }
    
    func testInit_whenInitiateLoginUseCaseEmittingChallengeFromBackgroundThread_thenSetsChallengeAvailableFromMainThread() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        expect(serverSetupViewModel[\.$challengeAvailable].dropFirst()).to(emit(onMainThread: true, when: { self.initiateLoginUseCaseMock.mockState(\.challenge, value: .success(self.challengeMock)) }, from: .init()))
    }
    
    func testInit_givenNonManagedServerAddress_whenInitiateLoginUseCaseFailing_thenSetsShowManagedServerAddressErrorAlertToFalse() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        initiateLoginUseCaseMock.mockState(\.challenge, value: .failure(ErrorMock.standard))
        
        expect(serverSetupViewModel[\.showManagedServerAddressErrorAlert]).toAlways(beFalse())
    }
    
    func testInit_givenManagedServerAddress_whenInitiateLoginUseCaseFailing_thenSetsShowManagedServerAddressErrorAlertToTrue() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random()))
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        initiateLoginUseCaseMock.mockState(\.challenge, value: .failure(ErrorMock.standard))
        
        expect(serverSetupViewModel[\.showManagedServerAddressErrorAlert]).toEventually(beTrue())
    }
    
    func testInit_whenInitiateLoginUseCaseFailingFromBackgroundThread_thenSetsShowManagedServerAddressErrorAlertFromMainThread() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        managedConfigurationUseCaseMock.mockState(\.serverUrl, value: .success(.random()))
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        expect(serverSetupViewModel[\.$showManagedServerAddressErrorAlert].dropFirst()).to(emit(onMainThread: true, when: { self.initiateLoginUseCaseMock.mockState(\.challenge, value: .failure(ErrorMock.standard)) }, from: .init()))
    }
    
    func testInit_whenInitiateLoginUseCaseFailing_thenSetsChallengeToNil() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        
        initiateLoginUseCaseMock.mockState(\.challenge, value: .failure(ErrorMock.standard))
        
        expect(serverSetupViewModel[\.challenge]).toAlways(beNil())
        expect(serverSetupViewModel[\.challengeAvailable]).toAlways(beFalse())
    }
    
    func testCallAsFunction_givenChallengeIsAvailable_whenCallingConnect_thenSetsShowLoginFlowPageToTrue() throws {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        loginUrlUseCaseMock.mockState(\.loginUrl, value: .success(loginUrlMock))
        userInitiatedSchedulerMock.run()
        initiateLoginUseCaseMock.mockState(\.challenge, value: .success(challengeMock))
        try require(serverSetupViewModel[\.challenge]).toEventuallyNot(beNil())
        try require(serverSetupViewModel[\.challengeAvailable]).toEventuallyNot(beFalse())
        
        serverSetupViewModel(.connect)
        
        expect(serverSetupViewModel[\.showLoginFlowPage]).to(beTrue())
    }
    
    func testCallAsFunction_givenChallengeIsNil_whenCallingConnect_thenDoesntSetShowLoginFlowPage() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        serverSetupViewModel(.connect)
        
        expect(serverSetupViewModel[\.showLoginFlowPage]).to(beFalse())
    }
    
    func testCallAsFunction_whenCallingCancel_thenShouldDismissEmits() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        
        expect(serverSetupViewModel[\.shouldDismiss]).to(emit(when: { serverSetupViewModel(.cancel) }))
    }
    
    func testCallAsFunction_whenCallingDismissKeyboard_thenSetsFocusedFieldToNil() {
        let serverSetupViewModel: any ServerSetupViewModelProtocol = ServerSetupViewModel()
        serverSetupViewModel[\.focusedField] = .serverAddress
        
        serverSetupViewModel(.dismissKeyboard)
        
        expect(serverSetupViewModel[\.focusedField]).to(beNil())
    }
    
}
