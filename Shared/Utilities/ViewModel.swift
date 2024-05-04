import Foundation


protocol ViewModel: ObservableObject, Stateful, Actionable where State: ObservableObject {}


extension ViewModel {
    
    var objectWillChange: State.ObjectWillChangePublisher {
        state.objectWillChange
    }
    
    func eraseToAnyViewModel() -> AnyViewModelOf<Self> {
        .init(self)
    }
    
}
