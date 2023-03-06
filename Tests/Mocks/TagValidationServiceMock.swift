@testable import Passwords
import Foundation


final class TagValidationServiceMock: TagValidationServiceProtocol, Mock, FunctionCallLogging {
    
    var functionCallLog = [(functionName: String, parameters: [any Equatable])]()
    
    var _validate = false // swiftlint:disable:this identifier_name
    func validate(label: String) -> Bool {
        logFunctionCall(parameters: label)
        return _validate
    }
    
}
