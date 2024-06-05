import XCTest
import Nimble
import Factory
@testable import Passwords


// swiftlint:disable state_access

final class ViewModelTests: XCTestCase { // swiftlint:disable:this file_types_order
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testObjectWillChange_whenChangingPublishedState_thenPublisherEmits() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        
        expect(basicViewModel.objectWillChange).to(emit(when: { basicViewModel.state.value = .random() }))
    }
    
    func testSubscript_whenGettingValueViaKeyPath_thenReturnsValueFromState() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        
        expect(basicViewModel[\.value as KeyPath]).to(equal(basicViewModel.state.value))
    }
    
    func testSubscript_whenGettingValueViaReferenceWritableKeyPath_thenReturnsValueFromState() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        
        expect(basicViewModel[\.value as ReferenceWritableKeyPath]).to(equal(basicViewModel.state.value))
    }
    
    func testSubscript_whenSettingValue_thenUpdatesValueInState() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        let newValue = String.random()
        
        basicViewModel[\.value] = newValue
        
        expect(basicViewModel.state.value).to(equal(newValue))
    }
    
    func testEraseToAnyViewModel_whenChangingStateOfErasedViewModelViaAction_thenContainsSameStateAndActionAsWrappedViewModel() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        let newValue = String.random()
        
        let result = basicViewModel.eraseToAnyViewModel()
        result(.setValue(newValue))
        
        expect(result.state).to(be(basicViewModel.state))
        expect(result.state.value).to(equal(basicViewModel.state.value))
        expect(result.state.value).to(equal(newValue))
    }
    
}

// swiftlint:enable state_access


protocol BasicViewModelProtocol: ViewModel where State == BasicViewModel.State, Action == BasicViewModel.Action {
    
    init(value: String)
    
}


final class BasicViewModel: BasicViewModelProtocol {
    
    final class State: ObservableObject {
        
        @Published var value: String
        
        init(value: String) {
            self.value = value
        }
        
    }
    
    enum Action {
        case setValue(String)
    }
    
    let state: State
    
    init(value: String) {
        state = .init(value: value)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setValue(newValue):
            state.value = newValue
        }
    }
    
}
