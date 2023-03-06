protocol FunctionCallLogging: AnyObject {
    
    typealias FunctionCall = (functionName: String, parameters: [any Equatable])
    
    var functionCallLog: [FunctionCall] { get set }
    
}


extension FunctionCallLogging {
    
    func functionCallLog(of functionName: String) -> [FunctionCall] {
        functionCallLog.filter { $0.functionName == functionName }
    }
    
    func logFunctionCall(of functionName: String = #function, parameters: any Equatable...) {
        functionCallLog.append((functionName: functionName, parameters: parameters))
    }
    
}
