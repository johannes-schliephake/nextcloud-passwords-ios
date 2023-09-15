@testable import Passwords


final class PasteboardServiceMock: PasteboardServiceProtocol, Mock, FunctionCallLogging {
    
    func set(_ string: String) {
        logFunctionCall(parameters: string)
    }
    
}
