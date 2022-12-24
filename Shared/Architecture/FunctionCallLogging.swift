#if DEBUG

protocol FunctionCallLogging: AnyObject {
    
    var functionCallLog: [(functionName: String, parameters: [Any])] { get set }
    
}


extension FunctionCallLogging {
    
    func logFunctionCall(of functionName: String = #function, parameters: [Any] = []) {
        functionCallLog.append((functionName: functionName, parameters: parameters))
    }
    
}

#endif
