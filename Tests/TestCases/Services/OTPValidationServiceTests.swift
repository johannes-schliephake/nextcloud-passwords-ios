import XCTest
import Nimble
import Factory
@testable import Passwords


final class OTPValidationServiceTests: XCTestCase {
    
    @Injected(\.otp) private var otpMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testValidate_givenEmptySecret_thenReturnsFalse() {
        let otpValidationService: any OTPValidationServiceProtocol = OTPValidationService()
        
        let result = otpValidationService.validate(type: .allCases.randomElement()!, secret: "", digits: .random(in: 6...8), counter: .random(in: 0...1000), period: .random(in: 1...1000))
        
        expect(result).to(beFalse())
    }
    
    func testValidate_givenValidSecret_thenReturnsTrue() {
        let otpValidationService: any OTPValidationServiceProtocol = OTPValidationService()
        
        let result = otpValidationService.validate(type: .allCases.randomElement()!, secret: otpMock.secret, digits: .random(in: 6...8), counter: .random(in: 0...1000), period: .random(in: 1...1000))
        
        expect(result).to(beTrue())
    }
    
    func testValidate_givenInvalidSecret_thenReturnsFalse() {
        let otpValidationService: any OTPValidationServiceProtocol = OTPValidationService()
        
        let result = otpValidationService.validate(type: .allCases.randomElement()!, secret: "1", digits: .random(in: 6...8), counter: .random(in: 0...1000), period: .random(in: 1...1000))
        
        expect(result).to(beFalse())
    }
    
    func testValidate_givenDifferentDigitsValues_thenAllowedDigitsValuesReturnTrue() {
        let otpValidationService: any OTPValidationServiceProtocol = OTPValidationService()
        let testDigitsValues = -1...10
        
        let result = testDigitsValues.map { otpValidationService.validate(type: .allCases.randomElement()!, secret: otpMock.secret, digits: $0, counter: .random(in: 0...1000), period: .random(in: 1...1000)) }
        
        let expectedResult = .init(repeating: false, count: 7) + .init(repeating: true, count: 3) + .init(repeating: false, count: 2)
        expect(result).to(equal(expectedResult))
    }
    
    func testValidate_givenTypeIsHotpAndDifferentCounters_thenAllowedCountersReturnTrue() {
        let otpValidationService: any OTPValidationServiceProtocol = OTPValidationService()
        let testCounters = -5...10
        
        let result = testCounters.map { otpValidationService.validate(type: .hotp, secret: otpMock.secret, digits: .random(in: 6...8), counter: $0, period: .random(in: 1...1000)) }
        
        let expectedResult = .init(repeating: false, count: 5) + .init(repeating: true, count: 11)
        expect(result).to(equal(expectedResult))
    }
    
    func testValidate_givenTypeIsTotpAndDifferentPeriods_thenAllowedPeriodsReturnTrue() {
        let otpValidationService: any OTPValidationServiceProtocol = OTPValidationService()
        let testPeriods = -5...10
        
        let result = testPeriods.map { otpValidationService.validate(type: .totp, secret: otpMock.secret, digits: .random(in: 6...8), counter: .random(in: 0...1000), period: $0) }
        
        let expectedResult = .init(repeating: false, count: 6) + .init(repeating: true, count: 10)
        expect(result).to(equal(expectedResult))
    }

}
