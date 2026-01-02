import XCTest
import Nimble
import Factory
@testable import Passwords


final class AuthenticationUseCaseTests: XCTestCase {
    
    private let challengeMock = LoginFlowChallenge(login: .random(), poll: .init(token: .random(), endpoint: .random()))
    
    @MockInjected(\.loginPollUseCase) private var loginPollUseCaseMock: LoginPollUseCaseMock
    @MockInjected(\.windowRepository) private var windowRepositoryMock: WindowRepositoryMock
    @MockInjected(\.webAuthenticationSessionType) private var webAuthenticationSessionTypeMock: WebAuthenticationSessionMock.Type
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
        webAuthenticationSessionTypeMock.functionCallLog.removeAll()
    }
    
    func testInit_thenSetsInitialState() {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        
        expect(authenticationUseCase[\.latestAttemptFailed]).to(beNil())
    }
    
    func testCallAsFunction_whenCallingSetChallenge_thenCallsLoginPollUseCase() {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        
        authenticationUseCase(.setChallenge(challengeMock))
        
        expect(self.loginPollUseCaseMock).to(beCalled(.once, on: "setPoll", withParameter: challengeMock.poll))
    }
    
    func testCallAsFunction_whenCallingSetChallenge_thenInitsWebAuthenticationSession() throws {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        
        authenticationUseCase(.setChallenge(challengeMock))
        
        let webAuthenticationSessionMock = try XCTUnwrap(webAuthenticationSessionTypeMock.functionCallLog.removeFirst().parameters.first as? WebAuthenticationSessionMock)
        expect(webAuthenticationSessionMock).to(beCalled(.once, on: "init(url:callbackURLScheme:completionHandler:)", withParameters: challengeMock.login, nil as String?))
    }
    
    func testCallAsFunction_givenSetChallengeCalled_whenCallingCompletionHandlerWithError_thenSetsLatestAttemptFailedToTrue() throws {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        authenticationUseCase(.setChallenge(challengeMock))
        let webAuthenticationSessionMock = try XCTUnwrap(webAuthenticationSessionTypeMock.functionCallLog.removeFirst().parameters.first as? WebAuthenticationSessionMock)
        
        let completionHandler = try XCTUnwrap(webAuthenticationSessionMock._initCompletionHandler)
        completionHandler(nil, ErrorMock.standard)
        
        expect(authenticationUseCase[\.latestAttemptFailed]).to(beTrue())
    }
    
    func testCallAsFunction_givenSetChallengeCalled_whenCallingCompletionHandlerWithoutError_thenSetsLatestAttemptFailedToFalse() throws {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        authenticationUseCase(.setChallenge(challengeMock))
        let webAuthenticationSessionMock = try XCTUnwrap(webAuthenticationSessionTypeMock.functionCallLog.removeFirst().parameters.first as? WebAuthenticationSessionMock)
        
        let completionHandler = try XCTUnwrap(webAuthenticationSessionMock._initCompletionHandler)
        completionHandler(nil, nil)
        
        expect(authenticationUseCase[\.latestAttemptFailed]).to(beFalse())
    }
    
    func testCallAsFunction_whenCallingSetChallengeAndNotCallingCompletionHandler_thenDoesntSetLatestAttemptFailed() throws {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        
        authenticationUseCase(.setChallenge(challengeMock))
        
        expect(authenticationUseCase[\.latestAttemptFailed]).to(beNil())
    }
    
    func testCallAsFunction_whenCallingSetChallenge_thenAccessesWindowRepository() {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        
        authenticationUseCase(.setChallenge(challengeMock))
        
        expect(self.windowRepositoryMock).to(beAccessed(.once, on: "window"))
    }
    
    func testCallAsFunction_whenCallingSetChallenge_thenSetsWindowOnWebAuthenticationSession() throws {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        let windowMock = WindowMock()
        windowRepositoryMock.mockState(\.window, value: .success(windowMock))
        
        authenticationUseCase(.setChallenge(challengeMock))
        
        let webAuthenticationSessionMock = try XCTUnwrap(webAuthenticationSessionTypeMock.functionCallLog.removeFirst().parameters.first as? WebAuthenticationSessionMock)
        expect(webAuthenticationSessionMock).to(beAccessed(.once, on: "window"))
        expect(webAuthenticationSessionMock._window).to(be(windowMock))
    }
    
    func testCallAsFunction_whenCallingSetChallenge_thenCallsStartOnWebAuthenticationSession() throws {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        let windowMock = WindowMock()
        windowRepositoryMock.mockState(\.window, value: .success(windowMock))
        
        authenticationUseCase(.setChallenge(challengeMock))
        
        let webAuthenticationSessionMock = try XCTUnwrap(webAuthenticationSessionTypeMock.functionCallLog.removeFirst().parameters.first as? WebAuthenticationSessionMock)
        expect(webAuthenticationSessionMock).to(beCalled(.once, on: "start()"))
    }
    
    func testCallAsFunction_whenCallingSetChallengeTwoTimes_thenCallsCancelOnFirstWebAuthenticationSession() throws {
        let authenticationUseCase: any AuthenticationUseCaseProtocol = AuthenticationUseCase()
        let windowMock = WindowMock()
        windowRepositoryMock.mockState(\.window, value: .success(windowMock))
        
        authenticationUseCase(.setChallenge(challengeMock))
        authenticationUseCase(.setChallenge(challengeMock))
        
        let webAuthenticationSessionMock1 = try XCTUnwrap(webAuthenticationSessionTypeMock.functionCallLog.removeFirst().parameters.first as? WebAuthenticationSessionMock)
        let webAuthenticationSessionMock2 = try XCTUnwrap(webAuthenticationSessionTypeMock.functionCallLog.removeFirst().parameters.first as? WebAuthenticationSessionMock)
        expect(webAuthenticationSessionMock1).to(beCalled(.once, on: "cancel()"))
        expect(webAuthenticationSessionMock2).toNot(beCalled(on: "cancel()"))
    }
    
}
