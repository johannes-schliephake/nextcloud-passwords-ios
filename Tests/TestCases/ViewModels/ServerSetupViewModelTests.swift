import XCTest
import Nimble
import Factory
@testable import Passwords


final class ServerSetupViewModelTests: XCTestCase {
    
    @LazyInjected(\.userInitiatedSchedulerMock) private var userInitiatedSchedulerMock
    @MockInjected(\.loginUrlUseCase) private var loginUrlUseCaseMock: LoginUrlUseCaseMock
    @MockInjected(\.managedConfigurationUseCase) private var managedConfigurationUseCaseMock: ManagedConfigurationUseCaseMock
    @MockInjected(\.initiateLoginUseCase) private var initiateLoginUseCaseMock: InitiateLoginUseCaseMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
}
