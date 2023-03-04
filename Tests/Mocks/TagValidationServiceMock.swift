@testable import Passwords


final class TagValidationServiceMock: TagValidationServiceProtocol, Mock, FunctionCallLogging {
    
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    var _validate = false // swiftlint:disable:this identifier_name
    func validate(label: String) -> Bool {
        logFunctionCall(parameters: [label])
        return _validate
    }
    
}
