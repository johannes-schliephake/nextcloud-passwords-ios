@testable import Passwords
import Factory


final class LogViewModelMock: ViewModelMock<LogViewModel.State, LogViewModel.Action>, LogViewModelProtocol {}


extension LogViewModel.State: Mock {
    
    convenience init() {
        let logEventMocks = resolve(\.logEvents)
        self.init(isAvailable: true, events: logEventMocks)
    }
    
}
