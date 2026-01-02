@testable import Passwords


final class AuthenticationUseCaseMock: AuthenticationUseCaseProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let state = AuthenticationUseCase.State()
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setChallenge(challenge):
            logFunctionCall(of: action, parameters: challenge)
        }
    }
    
}
