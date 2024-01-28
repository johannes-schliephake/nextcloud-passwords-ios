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
    
    subscript<Value, E: Error>(_ keyPath: KeyPath<State, Published<Result<Value, E>?>.Publisher>) -> some Publisher<Value, E> {
         state[keyPath: keyPath]
             .compactMap { $0 }
             .tryMap { result in
                 switch result {
                 case let .success(value):
                     return value
                 case let .failure(error):
                     throw error
                 }
             }
             .mapError { $0 as! E } // swiftlint:disable:this force_cast
     }
    
}


extension Stateful where State == EmptyState {
    
    var state: State {
        .init()
    }
    
}
