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
    
    subscript<Output>(_ keyPath: KeyPath<State, Published<Result<Output, Never>?>.Publisher>) -> AnyPublisher<Output, Never> {
        state[keyPath: keyPath]
            .compactMap { try! $0?.get() } // swiftlint:disable:this force_try
            .eraseToAnyPublisher()
     }
    
    subscript<Output, Failure: Error>(_ keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> {
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
             .mapError { $0 as! Failure } // swiftlint:disable:this force_cast
             .eraseToAnyPublisher()
     }
    
}


extension Stateful where State == EmptyState {
    
    var state: State {
        .init()
    }
    
}
