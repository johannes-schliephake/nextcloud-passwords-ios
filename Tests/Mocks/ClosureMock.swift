import Foundation


final class ClosureMock: FunctionCallLogging {
    
    var functionCallLog = [(functionName: String, parameters: [any Equatable])]()
    
    func log() {
        logFunctionCall()
    }
    
    func log(_ parameter1: any Equatable) {
        logFunctionCall(parameters: parameter1)
    }
    
    func log(_ parameter1: any Equatable, _ parameter2: any Equatable) {
        logFunctionCall(parameters: parameter1, parameter2)
    }
    
    func log(_ parameter1: any Equatable, _ parameter2: any Equatable, _ parameter3: any Equatable) {
        logFunctionCall(parameters: parameter1, parameter2, parameter3)
    }
    
}
