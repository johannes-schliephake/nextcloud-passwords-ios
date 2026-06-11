@testable import Passwords


final class WindowSizeUseCaseMock: WindowSizeUseCaseProtocol, Mock, PropertyAccessLogging {
    
    let state = WindowSizeUseCase.State()
    
}
