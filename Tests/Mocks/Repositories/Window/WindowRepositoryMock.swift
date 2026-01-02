@testable import Passwords


final class WindowRepositoryMock: WindowRepositoryProtocol, Mock, PropertyAccessLogging {
    
    let state = WindowRepository.State()
    
}
