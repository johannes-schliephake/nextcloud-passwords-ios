@testable import Passwords


final class InitiateLoginUseCaseMock: InitiateLoginUseCaseProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let state = InitiateLoginUseCase.State()
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setLoginUrl(loginUrl):
            logFunctionCall(of: action, parameters: loginUrl)
        }
    }
    
}
