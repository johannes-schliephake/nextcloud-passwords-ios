@testable import Passwords


final class ManagedConfigurationUseCaseMock: ManagedConfigurationUseCaseProtocol, Mock, PropertyAccessLogging {
    
    let state = ManagedConfigurationUseCase.State()
    
}
