@testable import Passwords
import Foundation


class ViewModelMock<State: ObservableObject & Mock, Action>: ViewModel, Mock, FunctionCallLogging {
    
    let state: State
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    required init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        logFunctionCall(parameters: [action])
    }
    
}
