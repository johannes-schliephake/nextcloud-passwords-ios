import Foundation


final class EmptyState: ObservableObject {}


protocol Stateful {
    
    associatedtype State: AnyObject
    
    var state: State { get }
    
    subscript<Value>(_ keyPath: KeyPath<State, Value>) -> Value { get }
    subscript<Value>(_ keyPath: ReferenceWritableKeyPath<State, Value>) -> Value { get nonmutating set }
    
}


extension Stateful {
    
    subscript<Value>(_ keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }
    
    subscript<Value>(_ keyPath: ReferenceWritableKeyPath<State, Value>) -> Value {
        get {
            state[keyPath: keyPath]
        }
        nonmutating set {
            state[keyPath: keyPath] = newValue
        }
    }
    
}


extension Stateful where State == EmptyState {
    
    var state: State {
        .init()
    }
    
}
