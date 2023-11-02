@testable import Passwords


final class PasteboardDataSourceMock: PasteboardDataSourceProtocol, Mock, FunctionCallLogging {
    
    func set(string: String, localOnly: Bool, sensitive: Bool) {
        logFunctionCall(parameters: string, localOnly, sensitive)
    }
    
}
