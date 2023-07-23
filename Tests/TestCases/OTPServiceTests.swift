import XCTest
import Nimble
import Factory
@testable import Passwords


final class OTPServiceTests: XCTestCase {
    
    @Injected(\.otp) private var otpMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testMakeOtpWithDetailedSignature_givenInvalidParameters_thenReturnsNil() {
        let otpService: any OTPServiceProtocol = OTPService()
        
        let result = otpService.makeOtp(type: .allCases.randomElement()!, algorithm: .allCases.randomElement()!, secret: "", digits: .random(in: -5...5), counter: .random(in: -10...(-1)), period: .random(in: -10...0))
        
        expect(result).to(beNil())
    }
    
    func testMakeOtpWithDetailedSignature_givenValidParameters_thenReturnsOtpWithMatchingProperties() {
        let otpService: any OTPServiceProtocol = OTPService()
        let expectedResult = OTP(type: .allCases.randomElement()!, algorithm: .allCases.randomElement()!, secret: otpMock.secret, digits: .random(in: 6...8), counter: .random(in: 0...1000), period: .random(in: 1...1000))!
        
        let result = otpService.makeOtp(type: expectedResult.type, algorithm: expectedResult.algorithm, secret: expectedResult.secret, digits: expectedResult.digits, counter: expectedResult.counter, period: expectedResult.period)
        
        expect(result).to(equal(expectedResult))
    }
    
    func testMakeOtpWithUrlStringSignature_givenInvalidUrlString_thenReturnsNil() {
        let otpService: any OTPServiceProtocol = OTPService()
        
        let result = otpService.makeOtp(urlString: "otpauth://")
        
        expect(result).to(beNil())
    }
    
    func testMakeOtpWithUrlStringSignature_givenValidUrlString_thenReturnsOtpWithMatchingProperties() {
        let otpService: any OTPServiceProtocol = OTPService()
        let expectedResult = OTP(type: .hotp, algorithm: .sha256, secret: "VTZCZF77FYE6YI4I", digits: 7, counter: 1, period: nil)!
        
        let result = otpService.makeOtp(urlString: "otpauth://hotp?algorithm=SHA256&secret=VTZCZF77FYE6YI4I&digits=7&counter=1")
        
        expect(result).to(equal(expectedResult))
    }
    
    func testHasDefaults_givenNonDefaultType_thenReturnsFalse() {
        let otpService: any OTPServiceProtocol = OTPService()
        let otpMock = OTP(type: .hotp, algorithm: nil, secret: otpMock.secret, digits: nil, counter: nil, period: nil)!
        
        let result = otpService.hasDefaults(otp: otpMock)
        
        expect(result).to(beFalse())
    }
    
    func testHasDefaults_givenNonDefaultAlgorithm_thenReturnsFalse() {
        let otpService: any OTPServiceProtocol = OTPService()
        let otpMock = OTP(type: OTP.Defaults.type, algorithm: .sha256, secret: otpMock.secret, digits: nil, counter: nil, period: nil)!
        
        let result = otpService.hasDefaults(otp: otpMock)
        
        expect(result).to(beFalse())
    }
    
    func testHasDefaults_givenNonDefaultDigitsValue_thenReturnsFalse() {
        let otpService: any OTPServiceProtocol = OTPService()
        let otpMock = OTP(type: OTP.Defaults.type, algorithm: nil, secret: otpMock.secret, digits: 7, counter: nil, period: nil)!
        
        let result = otpService.hasDefaults(otp: otpMock)
        
        expect(result).to(beFalse())
    }
    
    func testHasDefaults_givenNonDefaultPeriod_thenReturnsFalse() {
        let otpService: any OTPServiceProtocol = OTPService()
        let otpMock = OTP(type: OTP.Defaults.type, algorithm: nil, secret: otpMock.secret, digits: nil, counter: nil, period: 1)!
        
        let result = otpService.hasDefaults(otp: otpMock)
        
        expect(result).to(beFalse())
    }
    
    func testHasDefaults_givenDefaultParameters_thenReturnsTrue() {
        let otpService: any OTPServiceProtocol = OTPService()
        let otpMock = OTP(type: OTP.Defaults.type, algorithm: nil, secret: otpMock.secret, digits: nil, counter: nil, period: nil)!
        
        let result = otpService.hasDefaults(otp: otpMock)
        
        expect(result).to(beTrue())
    }
    
    func testOtpUrl_givenInvalidParameters_thenReturnsNil() {
        let otpService: any OTPServiceProtocol = OTPService()
        
        let result = otpService.otpUrl(type: .allCases.randomElement()!, algorithm: .allCases.randomElement()!, secret: "", digits: .random(in: -5...5), counter: .random(in: -10...(-1)), period: .random(in: -10...0), issuer: .random(), accountname: .random())
        
        expect(result).to(beNil())
    }
    
    func testOtpUrl_givenValidParameters_thenReturnsMatchingUrl() {
        let otpService: any OTPServiceProtocol = OTPService()
        let otpMock = OTP(type: .allCases.randomElement()!, algorithm: .allCases.randomElement()!, secret: otpMock.secret, digits: .random(in: 6...8), counter: .random(in: 0...1000), period: .random(in: 1...1000), issuer: .random(), accountname: .random())!
        
        let result = otpService.otpUrl(type: otpMock.type, algorithm: otpMock.algorithm, secret: otpMock.secret, digits: otpMock.digits, counter: otpMock.counter, period: otpMock.period, issuer: otpMock.issuer, accountname: otpMock.accountname)
        
        expect(result).to(equal(otpMock.url))
    }
    
}
