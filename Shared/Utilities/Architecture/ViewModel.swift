import Foundation
import Combine


protocol ViewModel: ObservableObject, Stateful, Actionable where State: ObservableObject {}


extension ViewModel {
    
    var objectWillChange: State.ObjectWillChangePublisher {
        state.objectWillChange
    }
    
    func eraseToAnyViewModel() -> AnyViewModelOf<Self> {
        .init(self)
    }
    
    /// Combines an action and a state publisher into an async call.
    /// - Parameters:
    ///   - action: The action to run.
    ///   - keyPath: A key path of a publisher that will emit the expected return value.
    /// - Returns: The first value emitted during or after running the action.
    func callAsFunction<Output, P: Publisher>(_ action: Action, returning keyPath: KeyPath<State, P>) async -> Output? where P.Output == Output, P.Failure == Never {
        
        /// Create a subject that mirrors the publisher but drops a potential initial value
        @Current(Output.self) var output
        let cancellable = self[keyPath].sink { output = .success($0) }
        defer { cancellable.cancel() }
        output = nil
        
        /// Run the action
        self(action)
        
        /// Publish stored value or first emitted value
        return await $output.values.first
    }
    
}
