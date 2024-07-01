@testable import Passwords


final class ServerSetupViewModelMock: ViewModelMock<ServerSetupViewModel.State, ServerSetupViewModel.Action>, ServerSetupViewModelProtocol {}


extension ServerSetupViewModel.State: Mock {
    
    convenience init() {
        self.init(serverAddress: "https://", isServerAddressManaged: false, showManagedServerAddressErrorAlert: false, isValidating: false, challenge: nil, challengeAvailable: false, showLoginFlowPage: false, focusedField: nil)
    }
    
}
