@testable import Passwords


final class WindowDataSourceMock: WindowDataSourceProtocol, Mock, PropertyAccessLogging {
    
    let state = WindowDataSource.State()
    
}
