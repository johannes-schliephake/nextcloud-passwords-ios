import ObjectiveC.runtime


protocol FunctionCallLogging: AnyObject {
    
    typealias Log = [(functionName: String, parameters: [any Equatable])]
    
    var functionCallLog: Log { get set }
    
}


private var kFunctionCallLog = malloc(1)


extension FunctionCallLogging {
    
    var functionCallLog: Log {
        get {
            guard let functionCallLog = objc_getAssociatedObject(self, &kFunctionCallLog) as? Log else {
                let functionCallLog = Log()
                self.functionCallLog = functionCallLog
                return functionCallLog
            }
            return functionCallLog
        }
        set {
            objc_setAssociatedObject(self, &kFunctionCallLog, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}


extension FunctionCallLogging {
    
    func functionCallLog(of functionName: String) -> Log {
        functionCallLog.filter { $0.functionName == functionName }
    }
    
    func logFunctionCall(of functionName: String = #function, parameters: any Equatable...) {
        functionCallLog.append((functionName: functionName, parameters: parameters))
    }
    
}
