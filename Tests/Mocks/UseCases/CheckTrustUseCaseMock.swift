@testable import Passwords


final class CheckTrustUseCaseMock: CheckTrustUseCaseProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let state = CheckTrustUseCase.State()
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setTrust(trust):
            logFunctionCall(of: action, parameters: trust)
        }
    }
    
}
