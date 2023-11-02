@testable import Passwords


final class PasteboardServiceMock: PasteboardServiceProtocol, Mock, FunctionCallLogging {
    
    func set(string: String, sensitive: Bool) {
        logFunctionCall(parameters: string, sensitive)
    }
    
}
