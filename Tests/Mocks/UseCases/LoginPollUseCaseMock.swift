@testable import Passwords


final class LoginPollUseCaseMock: LoginPollUseCaseProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let state = LoginPollUseCase.State()
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setDataStore(dataStore):
            logFunctionCall(of: action, parameters: dataStore as? WebDataStoreMock ?? String(describing: dataStore))
        case let .setPoll(poll):
            logFunctionCall(of: action, parameters: poll)
        case .startPolling:
            logFunctionCall(of: action)
        }
    }
    
}
