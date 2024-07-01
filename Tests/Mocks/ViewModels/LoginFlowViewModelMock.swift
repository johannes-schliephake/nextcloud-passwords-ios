@testable import Passwords
import Factory


final class LoginFlowViewModelMock: ViewModelMock<LoginFlowViewModel.State, LoginFlowViewModel.Action>, LoginFlowViewModelProtocol {
    
    convenience init(challenge: LoginFlowChallenge) {
        self.init()
    }
    
}


extension LoginFlowViewModel.State: Mock {
    
    convenience init() {
        let configurationTypeMock = resolve(\.configurationType)
        let nonPersistentWebDataStoreMock = resolve(\.nonPersistentWebDataStore)
        self.init(request: .init(url: .init(string: ".")!), userAgent: configurationTypeMock.clientName, dataStore: nonPersistentWebDataStoreMock, isLoading: false)
    }
    
}
