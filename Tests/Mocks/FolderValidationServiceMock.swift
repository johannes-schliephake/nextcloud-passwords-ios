@testable import Passwords


final class FolderValidationServiceMock: FolderValidationServiceProtocol, Mock, FunctionCallLogging {
    
    var _validate = false // swiftlint:disable:this identifier_name
    func validate(label: String, parent: String?) -> Bool {
        logFunctionCall(parameters: label, parent)
        return _validate
    }
    
}
