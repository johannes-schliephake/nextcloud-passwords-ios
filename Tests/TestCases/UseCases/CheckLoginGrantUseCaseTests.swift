import XCTest
import Nimble
import Factory
@testable import Passwords


final class CheckLoginGrantUseCaseTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        
        expect(checkLoginGrantUseCase[\.granted]).to(beNil())
    }
    
    func testCallAsFunction_givenGrantUrl_whenCallingSetUrl_thenSetsGrantedToTrue() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        let urlMock = URL(string: "https://cloud.example.com/login/v2/grant")!
        
        checkLoginGrantUseCase(.setUrl(urlMock))
        
        expect(checkLoginGrantUseCase[\.granted]).to(beSuccess { value in
            expect(value).to(beTrue())
        })
    }
    
    func testCallAsFunction_givenGrantUrlWithPathPrefix_whenCallingSetUrl_thenSetsGrantedToTrue() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        let urlMock = URL(string: "https://cloud.example.com/index.php/login/v2/grant")!
        
        checkLoginGrantUseCase(.setUrl(urlMock))
        
        expect(checkLoginGrantUseCase[\.granted]).to(beSuccess { value in
            expect(value).to(beTrue())
        })
    }
    
    func testCallAsFunction_givenGrantUrlWithQuery_whenCallingSetUrl_thenSetsGrantedToFalse() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        let urlMock = URL(string: "https://cloud.example.com/login/v2/grant?\(String.random())")!
        
        checkLoginGrantUseCase(.setUrl(urlMock))
        
        expect(checkLoginGrantUseCase[\.granted]).to(beSuccess { value in
            expect(value).to(beFalse())
        })
    }
    
    func testCallAsFunction_givenGrantUrlWithFragment_whenCallingSetUrl_thenSetsGrantedToFalse() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        let urlMock = URL(string: "https://cloud.example.com/login/v2/grant#\(String.random())")!
        
        checkLoginGrantUseCase(.setUrl(urlMock))
        
        expect(checkLoginGrantUseCase[\.granted]).to(beSuccess { value in
            expect(value).to(beFalse())
        })
    }
    
    func testCallAsFunction_givenApptokenUrl_whenCallingSetUrl_thenSetsGrantedToTrue() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        let urlMock = URL(string: "https://cloud.example.com/login/v2/apptoken")!
        
        checkLoginGrantUseCase(.setUrl(urlMock))
        
        expect(checkLoginGrantUseCase[\.granted]).to(beSuccess { value in
            expect(value).to(beTrue())
        })
    }
    
    func testCallAsFunction_givenApptokenUrlWithPathPrefix_whenCallingSetUrl_thenSetsGrantedToTrue() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        let urlMock = URL(string: "https://cloud.example.com/index.php/login/v2/apptoken")!
        
        checkLoginGrantUseCase(.setUrl(urlMock))
        
        expect(checkLoginGrantUseCase[\.granted]).to(beSuccess { value in
            expect(value).to(beTrue())
        })
    }
    
    func testCallAsFunction_givenApptokenUrlWithQuery_whenCallingSetUrl_thenSetsGrantedToFalse() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        let urlMock = URL(string: "https://cloud.example.com/login/v2/apptoken?\(String.random())")!
        
        checkLoginGrantUseCase(.setUrl(urlMock))
        
        expect(checkLoginGrantUseCase[\.granted]).to(beSuccess { value in
            expect(value).to(beFalse())
        })
    }
    
    func testCallAsFunction_givenApptokenUrlWithFragment_whenCallingSetUrl_thenSetsGrantedToFalse() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        let urlMock = URL(string: "https://cloud.example.com/login/v2/apptoken#\(String.random())")!
        
        checkLoginGrantUseCase(.setUrl(urlMock))
        
        expect(checkLoginGrantUseCase[\.granted]).to(beSuccess { value in
            expect(value).to(beFalse())
        })
    }
    
    func testCallAsFunction_givenRandomUrl_whenCallingSetUrl_thenSetsGrantedToFalse() {
        let checkLoginGrantUseCase: any CheckLoginGrantUseCaseProtocol = CheckLoginGrantUseCase()
        let urlMock = URL.random()
        
        checkLoginGrantUseCase(.setUrl(urlMock))
        
        expect(checkLoginGrantUseCase[\.granted]).to(beSuccess { value in
            expect(value).to(beFalse())
        })
    }
    
}
