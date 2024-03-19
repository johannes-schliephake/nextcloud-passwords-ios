import Foundation


protocol ViewModel: ObservableObject, Stateful, Actionable where State: ObservableObject {}


extension ViewModel {
    
    var objectWillChange: State.ObjectWillChangePublisher {
        state.objectWillChange
    }
    
    func eraseToAnyViewModel() -> AnyViewModel<State, Action> {
        .init(self)
    }
    
}
