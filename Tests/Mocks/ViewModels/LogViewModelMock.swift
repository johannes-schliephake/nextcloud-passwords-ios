@testable import Passwords
import FactoryKit


final class LogViewModelMock: ViewModelMock<LogViewModel.State, LogViewModel.Action>, LogViewModelProtocol {}


extension LogViewModel.State: Mock {
    
    convenience init() {
        let logEventMocks = dependency(\.logEvents)
        self.init(isAvailable: true, events: logEventMocks)
    }
    
}
