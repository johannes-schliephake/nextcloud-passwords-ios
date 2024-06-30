@testable import Passwords


final class CheckLoginGrantUseCaseMock: CheckLoginGrantUseCaseProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let state = CheckLoginGrantUseCase.State()
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setUrl(url):
            logFunctionCall(of: action, parameters: url)
        }
    }
    
}
