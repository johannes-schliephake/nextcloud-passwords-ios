import XCTest
import Nimble
import FactoryKit
@testable import Passwords


@available(iOS 17, *) final class OpenProviderSettingsUseCaseTests: XCTestCase {
    
    @MockInjected(\.credentialProviderSettingsHelperType) private var credentialProviderSettingsHelperTypeMock: CredentialProviderSettingsHelperMock.Type
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        guard #available(iOS 17, *) else { // Don't trust Xcode, this warning is wrong, XCTest will try to run this on iOS 16
            throw XCTSkip()
        }
    }
    
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
