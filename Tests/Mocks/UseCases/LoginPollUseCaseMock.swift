@testable import Passwords


final class LoginPollUseCaseMock: LoginPollUseCaseProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let state = LoginPollUseCase.State()
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setPoll(poll):
            logFunctionCall(of: action, parameters: poll)
        }
    }
    
}
