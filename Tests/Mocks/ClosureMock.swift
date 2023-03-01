final class ClosureMock: FunctionCallLogging {
    
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    func log(_ parameter1: Any) {
        logFunctionCall(parameters: [parameter1])
    }
    
    func log(_ parameter1: Any, _ parameter2: Any) {
        logFunctionCall(parameters: [parameter1, parameter2])
    }
    
    func log(_ parameter1: Any, _ parameter2: Any, _ parameter3: Any) {
        logFunctionCall(parameters: [parameter1, parameter2, parameter3])
    }
    
}
