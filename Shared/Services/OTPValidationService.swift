import Foundation


protocol OTPValidationServiceProtocol {
    
    func validate(type: OTP.OTPType, secret: String, digits: Int, counter: Int, period: Int) -> Bool
    
}


struct OTPValidationService: OTPValidationServiceProtocol {
    
    func validate(type: OTP.OTPType, secret: String, digits: Int, counter: Int, period: Int) -> Bool {
        !secret.isEmpty &&
        Data(base32Encoded: secret) != nil &&
        6...8 ~= digits &&
        (type == .hotp && counter >= 0 || type == .totp && period > 0)
    }
    
}
