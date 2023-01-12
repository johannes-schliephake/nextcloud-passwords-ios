import XCTest
@testable import Passwords
import Factory
import Combine


final class ViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Container.registerMocks()
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.Registrations.reset()
    }

    func testObjectWillChange_changePublishedState_publisherEmits() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        
        let expectation = expectation(description: "objectWillChange emitted")
        var cancellables = Set<AnyCancellable>()
        basicViewModel.objectWillChange
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        basicViewModel.state.value = .random()

        waitForExpectations(timeout: 0.1)
    }
    
    func testSubscript_getValueViaKeyPath_returnsValueFromState() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        
        let result = basicViewModel[\.value as KeyPath]
        
        XCTAssertEqual(result, basicViewModel.state.value)
    }
    
    func testSubscript_getValueViaReferenceWritableKeyPath_returnsValueFromState() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        
        let result = basicViewModel[\.value as ReferenceWritableKeyPath]
        
        XCTAssertEqual(result, basicViewModel.state.value)
    }
    
    func testSubscript_setValue_updatesValueInState() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        
        let newValue = String.random()
        basicViewModel[\.value] = newValue
        
        XCTAssertEqual(basicViewModel.state.value, newValue)
    }
    
    func testEraseToAnyViewModel_changeStateOfErasedViewModelViaAction_containsSameStateAndActionAsWrappedViewModel() {
        let basicViewModel: any BasicViewModelProtocol = BasicViewModel(value: .random())
        
        let newValue = String.random()
        let result = basicViewModel.eraseToAnyViewModel()
        result(.setValue(newValue: newValue))
        
        XCTAssert(result.state === basicViewModel.state)
        XCTAssertEqual(result.state.value, basicViewModel.state.value)
        XCTAssertEqual(result.state.value, newValue)
    }
    
}


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
        case setValue(newValue: String)
    }
    
    let state: State
    
    init(value: String) {
        state = .init(value: value)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setValue(newValue: newValue):
            state.value = newValue
        }
    }
    
}
