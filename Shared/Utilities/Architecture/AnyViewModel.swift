import Foundation


typealias AnyViewModelOf<VM: ViewModel> = AnyViewModel<VM.State, VM.Action>


final class AnyViewModel<State: ObservableObject, Action>: ViewModel {
    
    let state: State
    
    private let wrappedCallAsFunction: (Action) -> Void

    init<WrappableViewModel: ViewModel>(_ wrappableViewModel: WrappableViewModel) where WrappableViewModel.State == State, WrappableViewModel.Action == Action {
        state = wrappableViewModel.state // swiftlint:disable:this state_access
        wrappedCallAsFunction = wrappableViewModel.callAsFunction
    }

    func callAsFunction(_ action: Action) {
        wrappedCallAsFunction(action)
    }
    
}
