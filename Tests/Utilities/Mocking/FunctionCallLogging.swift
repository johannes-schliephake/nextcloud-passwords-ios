protocol FunctionCallLogging: AnyObject, Associating {
    
    typealias Log = [(functionName: String, parameters: [any Equatable])]
    
    static var functionCallLog: Log { get set }
    var functionCallLog: Log { get set }
    
}


extension FunctionCallLogging {
    
    static var functionCallLog: Log {
        get { getAssociated() }
        set { setAssociated(newValue) }
    }
    
    var functionCallLog: Log {
        get { getAssociated() }
        set { setAssociated(newValue) }
    }
    
    static func functionCallLog(of functionName: String) -> Log {
        functionCallLog.filter { $0.functionName == functionName }
    }
    
    static func logFunctionCall(of functionName: String = #function, parameters: any Equatable...) {
        functionCallLog.append((functionName: functionName, parameters: parameters))
    }
    
    func functionCallLog(of functionName: String) -> Log {
        functionCallLog.filter { $0.functionName == functionName }
    }
    
    func logFunctionCall(of functionName: String = #function, parameters: any Equatable...) {
        functionCallLog.append((functionName: functionName, parameters: parameters))
    }
    
}
