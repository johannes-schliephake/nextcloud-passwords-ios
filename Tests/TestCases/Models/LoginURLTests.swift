import XCTest
import Nimble
import Factory
@testable import Passwords


final class LoginURLTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_givenHttpsDomain_thenIsNotNil() {
        let loginUrl = LoginURL(string: "https://example.com")
        
        expect(loginUrl?.value).to(equal(.init(string: "https://example.com/index.php/login/v2")!))
    }
    
    func testInit_givenHttpsSubdomain_thenIsNotNil() {
        let loginUrl = LoginURL(string: "https://cloud.example.com")
        
        expect(loginUrl?.value).to(equal(.init(string: "https://cloud.example.com/index.php/login/v2")!))
    }
    
    func testInit_givenHttpsDomainAndPath_thenIsNotNil() {
        let loginUrl = LoginURL(string: "https://example.com/nextcloud")
        
        expect(loginUrl?.value).to(equal(.init(string: "https://example.com/nextcloud/index.php/login/v2")!))
    }
    
    func testInit_givenHttpsDomainAndPort_thenIsNotNil() {
        let loginUrl = LoginURL(string: "https://example.com:8080")
        
        expect(loginUrl?.value).to(equal(.init(string: "https://example.com:8080/index.php/login/v2")!))
    }
    
    func testInit_givenHttps_thenIsNil() {
        let loginUrl = LoginURL(string: "https://")
        
        expect(loginUrl).to(beNil())
    }
    
    func testInit_givenHttpsPath_thenIsNil() {
        let loginUrl = LoginURL(string: "https:///nextcloud")
        
        expect(loginUrl).to(beNil())
    }
    
    func testInit_givenHttpDomain_thenIsNil() {
        let loginUrl = LoginURL(string: "http://example.com")
        
        expect(loginUrl).to(beNil())
    }
    
    func testInit_givenHttpSubdomain_thenIsNil() {
        let loginUrl = LoginURL(string: "http://cloud.example.com")
        
        expect(loginUrl).to(beNil())
    }
    
    func testInit_givenHttpDomainAndPath_thenIsNil() {
        let loginUrl = LoginURL(string: "http://example.com/nextcloud")
        
        expect(loginUrl).to(beNil())
    }
    
    func testInit_givenHttpDomainAndPort_thenIsNil() {
        let loginUrl = LoginURL(string: "http://example.com:8080")
        
        expect(loginUrl).to(beNil())
    }
    
    func testInit_givenSftpDomain_thenIsNil() {
        let loginUrl = LoginURL(string: "sftp://example.com")
        
        expect(loginUrl).to(beNil())
    }
    
    func testInit_givenRandomString_thenIsNil() {
        let loginUrl = LoginURL(string: .random())
        
        expect(loginUrl).to(beNil())
    }
    
    func testInit_givenEmptyString_thenIsNil() {
        let loginUrl = LoginURL(string: "")
        
        expect(loginUrl).to(beNil())
    }
    
}
