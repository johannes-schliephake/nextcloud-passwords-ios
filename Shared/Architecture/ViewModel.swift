import Foundation


protocol ViewModel: ObservableObject {
    
    associatedtype State: ObservableObject
    associatedtype Action
    
    var state: State { get }
    
    func callAsFunction(_ action: Action)
    
}


extension ViewModel {
    
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


extension ViewModel where Action == Never {
    
    func callAsFunction(_ action: Action) {}
    
}
