import Foundation


protocol ViewModel: ObservableObject { // swiftlint:disable:this file_types_order
    
    associatedtype State: ObservableObject
    associatedtype Action
    
    var state: State { get }
    
    func callAsFunction(_ action: Action)
    
}


extension ViewModel { // swiftlint:disable:this file_types_order
    
    var objectWillChange: State.ObjectWillChangePublisher {
        state.objectWillChange
    }
    
    subscript<Value>(_ keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }
    
    subscript<Value>(_ keyPath: ReferenceWritableKeyPath<State, Value>) -> Value {
        get {
            state[keyPath: keyPath]
        }
        set {
            state[keyPath: keyPath] = newValue
        }
    }
    
    func eraseToAnyViewModel() -> AnyViewModel<State, Action> {
        .init(self)
    }
    
}


extension ViewModel where Action == Never { // swiftlint:disable:this file_types_order
    
    func callAsFunction(_ action: Action) {}
    
}


#if DEBUG

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

#endif
