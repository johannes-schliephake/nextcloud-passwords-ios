@testable import Passwords


final class PasteboardRepositoryMock: PasteboardRepositoryProtocol, Mock, FunctionCallLogging {
    
    func set(string: String, sensitive: Bool) {
        logFunctionCall(parameters: string, sensitive)
    }
    
}
