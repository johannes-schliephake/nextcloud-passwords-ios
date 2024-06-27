@testable import Passwords


extension Actionable where Self: FunctionCallLogging {
    
    func logFunctionCall(of action: Action, parameters: any Equatable...) {
        let functionName = String(describing: action).prefix { $0 != "(" }
        functionCallLog.append((functionName: String(functionName), parameters: parameters))
    }
    
}
