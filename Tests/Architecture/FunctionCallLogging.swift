protocol FunctionCallLogging: AnyObject {
    
    typealias FunctionCall = (functionName: String, parameters: [Any])
    
    var functionCallLog: [FunctionCall] { get set }
    
}


extension FunctionCallLogging {
    
    func functionCallLog(of functionName: String) -> [FunctionCall] {
        functionCallLog.filter { $0.functionName == functionName }
    }
    
    func logFunctionCall(of functionName: String = #function, parameters: [Any] = []) {
        functionCallLog.append((functionName: functionName, parameters: parameters))
    }
    
}
