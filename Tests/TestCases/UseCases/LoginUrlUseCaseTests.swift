import XCTest
import Nimble
import Factory
@testable import Passwords


final class LoginUrlUseCaseTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testCallAsFunction_givenInvalidString_whenCallingSetString_thenSetsLoginUrl() {
        let loginUrlUseCase: any LoginUrlUseCaseProtocol = LoginUrlUseCase()
        
        loginUrlUseCase(.setString(.random()))
        
        expect(loginUrlUseCase[\.loginUrl]).to(beSuccess { value in
            expect(value).to(beNil())
        })
    }
    
    func testCallAsFunction_givenValidString_whenCallingSetString_thenSetsLoginUrl() {
        let loginUrlUseCase: any LoginUrlUseCaseProtocol = LoginUrlUseCase()
        let urlStringMock = "https://example.com"
        
        loginUrlUseCase(.setString(urlStringMock))
        
        expect(loginUrlUseCase[\.loginUrl]).to(beSuccess { value in
            expect(value).to(equal(.init(string: urlStringMock)!))
        })
    }
    
}
