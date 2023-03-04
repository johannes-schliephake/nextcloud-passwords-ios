@testable import Passwords


final class FolderValidationServiceMock: FolderValidationServiceProtocol, Mock, FunctionCallLogging {
    
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    var _validate = false // swiftlint:disable:this identifier_name
    func validate(label: String, parent: String?) -> Bool {
        logFunctionCall(parameters: [label, parent as Any])
        return _validate
    }
    
}
