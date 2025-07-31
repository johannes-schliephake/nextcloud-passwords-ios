import XCTest
import Nimble
import Factory
@testable import Passwords


final class LoginFlowViewModelTests: XCTestCase {
    
    private let challengeMock = LoginFlowChallenge(login: .random(), poll: .init(token: .random(), endpoint: .random()))
    
    @MockInjected(\.checkLoginGrantUseCase) private var checkLoginGrantUseCaseMock: CheckLoginGrantUseCaseMock
    @MockInjected(\.checkTrustUseCase) private var checkTrustUseCaseMock: CheckTrustUseCaseMock
    @MockInjected(\.loginPollUseCase) private var loginPollUseCaseMock: LoginPollUseCaseMock
    @MockInjected(\.nonPersistentWebDataStore) private var nonPersistentWebDataStoreMock: WebDataStoreMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
        ConfigurationMock.clientName = "Mock"
        ConfigurationMock.preferredLocaleIdentifier = "en-US"
    }
    
    func testInit_thenSetsInitialState() {
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        
        expect(loginFlowViewModel[\.request].url).to(equal(challengeMock.login))
        expect(loginFlowViewModel[\.request].allHTTPHeaderFields).to(equal(["Accept-Language": "en-US"]))
        expect(loginFlowViewModel[\.userAgent]).to(equal("Mock"))
        expect(loginFlowViewModel[\.dataStore]).to(be(nonPersistentWebDataStoreMock))
        expect(loginFlowViewModel[\.isLoading]).to(beTrue())
        expect(loginFlowViewModel[\.isTrusted]).to(beNil())
    }
    
    func testInit_thenCallsLoginPollUseCase() {
        _ = LoginFlowViewModel(challenge: challengeMock)
        
        expect(self.loginPollUseCaseMock).to(beCalled(.once, on: "setDataStore", withParameter: nonPersistentWebDataStoreMock))
        expect(self.loginPollUseCaseMock).to(beCalled(.once, on: "setPoll", withParameter: challengeMock.poll))
    }
    
    func testInit_thenAccessesCheckLoginGrantUseCase() {
        _ = LoginFlowViewModel(challenge: challengeMock)
        
        expect(self.checkLoginGrantUseCaseMock).to(beAccessed(.once, on: "$granted"))
    }
    
    func testInit_thenAccessesCheckTrustUseCase() {
        _ = LoginFlowViewModel(challenge: challengeMock)
        
        expect(self.checkTrustUseCaseMock).to(beAccessed(.once, on: "$isTrusted"))
    }
    
    func testInit_givenNoPreferredLocale_thenSetsRequestWithoutHeaderFields() {
        ConfigurationMock.preferredLocaleIdentifier = nil
        
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        
        expect(loginFlowViewModel[\.request].allHTTPHeaderFields).to(beNil())
    }
    
    func testInit_givenRandomPreferredLocale_thenSetsRequestHeaderFields() {
        let preferredLocaleMock = String.random()
        ConfigurationMock.preferredLocaleIdentifier = preferredLocaleMock
        
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        
        expect(loginFlowViewModel[\.request].allHTTPHeaderFields).to(equal(["Accept-Language": preferredLocaleMock]))
    }
    
    func testInit_whenSettingRequest_thenCallsCheckLoginGrantUseCase() {
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        let urlMock = URL.random()
        let requestMock = URLRequest(url: urlMock)
        
        loginFlowViewModel[\.request] = requestMock
        
        expect(self.checkLoginGrantUseCaseMock).to(beCalled(.once, on: "setUrl", withParameter: urlMock))
    }
    
    func testInit_whenCheckLoginGrantUseCaseEmittingGrantedTrue_thenCallsLoginPollUseCase() {
        withExtendedLifetime(LoginFlowViewModel(challenge: challengeMock)) {
            checkLoginGrantUseCaseMock.mockState(\.granted, value: .success(true))
            
            expect(self.loginPollUseCaseMock).to(beCalled(.once, on: "startPolling"))
        }
    }
    
    func testInit_whenCheckLoginGrantUseCaseEmittingGrantedFalse_thenDoesntCallLoginPollUseCase() {
        withExtendedLifetime(LoginFlowViewModel(challenge: challengeMock)) {
            checkLoginGrantUseCaseMock.mockState(\.granted, value: .success(false))
            
            expect(self.loginPollUseCaseMock).toNot(beCalled(on: "startPolling"))
        }
    }
    
    func testInit_whenCheckLoginGrantUseCaseEmittingGrantedTrue_thenSetsIsLoadingToTrue() throws {
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        loginFlowViewModel(.updateLoadingState(false))
        try require(loginFlowViewModel[\.isLoading]).to(beFalse())
        
        checkLoginGrantUseCaseMock.mockState(\.granted, value: .success(true))
        
        expect(loginFlowViewModel[\.isLoading]).to(beTrue())
    }
    
    func testInit_whenCheckLoginGrantUseCaseEmittingGrantedFalse_thenDoesntSetIsLoading() throws {
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        try require(loginFlowViewModel[\.isLoading]).to(beTrue())
        
        checkLoginGrantUseCaseMock.mockState(\.granted, value: .success(false))
        
        expect(loginFlowViewModel[\.isLoading]).to(beTrue())
    }
    
    func testInit_whenCheckTrustUseCaseEmittingIsTrusted_thenSetsIsTrusted() {
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        let isTrustedMock = Bool.random()
        
        checkTrustUseCaseMock.mockState(\.isTrusted, value: .success(isTrustedMock))
        
        expect(loginFlowViewModel[\.isTrusted]).to(beSuccess { value in
            expect(value).to(equal(isTrustedMock))
        })
    }
    
    func testCallAsFunction_whenCallingCheckTrust_thenCallsCheckTrustUseCase() throws {
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        let certificateData = Data(base64Encoded: "MIIC+zCCAeOgAwIBAgIUTwFq3ChzXrHH8kB0Vq0yZXTeafUwDQYJKoZIhvcNAQELBQAwDTELMAkGA1UEBhMCREUwHhcNMjQwNjMwMTMwMjA3WhcNMjQwNzMwMTMwMjA3WjANMQswCQYDVQQGEwJERTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJuDA9n/3z0bdypoOHXoSaY4+Av6O2fax22fhzlAG5/FyyVZJCDvrZaSi7sZTy5KHpQDcRLiIwMU/RJfejp/sV7VlR3Cp+RSNSEWT504MiZpE9jfeQtKttXiNZKGXJNjVV7hfNUrhDSCKeVUZY3W8U3RmvnUAYKMhj0OYx5UsAMnfPNoh8Qqmt5yz9203pAt6CZOXtrhnhu20pOTt40Z/5ytlsViVlVZ6eH4orRlr+ecas0WjXtk2s+0mjiEtWpMJr0NLaEpv1CKeEzU1r0K5GjhKx3atGwXXNxrs364uUT8wHqBNYK4QQOqxugOTxxzuP+NgI5apDBA4B+aOIkyQAkCAwEAAaNTMFEwHQYDVR0OBBYEFMAGC++xdYPrjJ0h6WhMvkgJvxsoMB8GA1UdIwQYMBaAFMAGC++xdYPrjJ0h6WhMvkgJvxsoMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAHofj3rOP8Canx92C2NKcsXIxXXLqwYyYkN6nzL882ieKvGKtrSCxdljHly64vE51vz8QaeKNXCxkWzGvrvruWhcMqS6DFvwcEPorer7nnIYDZ90Zc9RfMOcyFaDxKB7X3If5E0MdQRl8rDcDD/iWTuR0uAaK39IMOODWldkLbQBGzAaI7oXmjhVihunnFATNWnHuMyG1hOUAlaSKzjHyVRieOLool0Z94FznDFyEeyK0Scwt96RubGEoQ8hYDGdhouswF+pJtjska72ohF/hUzVv05RXrf/9kTi7Z9wezAN4vTkI/R27cVVY+fP+fpOu4EC+1sz3OI0OCMPixykKPQ=")!
        let certificate = SecCertificateCreateWithData(nil, certificateData as CFData)!
        var trust: SecTrust! // swiftlint:disable:this implicitly_unwrapped_optional
        try require(SecTrustCreateWithCertificates(certificate, nil, &trust)).to(equal(errSecSuccess))
        
        loginFlowViewModel(.checkTrust(trust))
        
        expect(self.checkTrustUseCaseMock).to(beCalled(.once, on: "setTrust", withParameter: trust))
    }
    
    func testCallAsFunction_whenCallingUpdateLoadingState_thenSetsIsLoading() {
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        let isLoadingMock = Bool.random()
        
        loginFlowViewModel(.updateLoadingState(isLoadingMock))
        
        expect(loginFlowViewModel[\.isLoading]).to(equal(isLoadingMock))
    }
    
    func testCallAsFunction_givenCheckLoginGrantUseCaseEmittingGrantedTrue_whenCallingUpdateLoadingState_thenDoesntSetIsLoading() throws {
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        checkLoginGrantUseCaseMock.mockState(\.granted, value: .success(true))
        try require(loginFlowViewModel[\.isLoading]).to(beTrue())
        
        loginFlowViewModel(.updateLoadingState(false))
        
        expect(loginFlowViewModel[\.isLoading]).to(beTrue())
    }
    
    func testCallAsFunction_givenCheckLoginGrantUseCaseEmittingGrantedFalse_whenCallingUpdateLoadingState_thenSetsIsLoading() throws {
        let loginFlowViewModel: any LoginFlowViewModelProtocol = LoginFlowViewModel(challenge: challengeMock)
        checkLoginGrantUseCaseMock.mockState(\.granted, value: .success(false))
        try require(loginFlowViewModel[\.isLoading]).to(beTrue())
        
        loginFlowViewModel(.updateLoadingState(false))
        
        expect(loginFlowViewModel[\.isLoading]).to(beFalse())
    }
    
}
