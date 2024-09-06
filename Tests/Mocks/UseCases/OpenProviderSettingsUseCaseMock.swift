@testable import Passwords


final class OpenProviderSettingsUseCaseMock: OpenProviderSettingsUseCaseProtocol, Mock, FunctionCallLogging {
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .open:
            logFunctionCall(of: action)
        }
    }
    
}
