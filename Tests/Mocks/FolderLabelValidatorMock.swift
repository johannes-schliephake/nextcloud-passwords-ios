@testable import Passwords


final class FolderLabelValidatorMock: FolderLabelValidating, Mock, FunctionCallLogging {
    
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    var _validateEntity = false // swiftlint:disable:this identifier_name
    func validate(_ entity: String) -> Bool {
        logFunctionCall(parameters: [entity])
        return _validateEntity
    }
    
}
