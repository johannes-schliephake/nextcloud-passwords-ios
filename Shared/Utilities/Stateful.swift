import Combine
import Foundation


final class EmptyState: ObservableObject {}


protocol Stateful {
    
    associatedtype State: ObservableObject
    
    var state: State { get }
    
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
    
    subscript<Output, Failure>(_ keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> {
        state[keyPath: keyPath]
            .compactFlatMap { $0?.publisher }
            .eraseToAnyPublisher()
    }
    
}


extension Stateful where State == EmptyState {
    
    var state: State {
        .init()
    }
    
}
