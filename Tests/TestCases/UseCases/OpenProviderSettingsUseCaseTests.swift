import XCTest
import Nimble
import Factory
@testable import Passwords


@available(iOS 17, *) final class OpenProviderSettingsUseCaseTests: XCTestCase {
    
    @MockInjected(\.credentialProviderSettingsHelperType) private var credentialProviderSettingsHelperTypeMock: CredentialProviderSettingsHelperMock.Type
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testCallAsFunction_whenCallingOpen_thenCallsCredentialProviderSettingsHelperType() {
        let openProviderSettingsUseCase: any OpenProviderSettingsUseCaseProtocol = OpenProviderSettingsUseCase()
        
        openProviderSettingsUseCase(.open)
        
        expect(self.credentialProviderSettingsHelperTypeMock).to(beCalled(.once, on: "openCredentialProviderAppSettings(completionHandler:)"))
    }
    
}
