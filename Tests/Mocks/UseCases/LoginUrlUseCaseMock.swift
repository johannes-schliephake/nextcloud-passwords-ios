@testable import Passwords


final class LoginUrlUseCaseMock: LoginUrlUseCaseProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let state = LoginUrlUseCase.State()
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setString(string):
            logFunctionCall(of: action, parameters: string)
        }
    }
    
}
