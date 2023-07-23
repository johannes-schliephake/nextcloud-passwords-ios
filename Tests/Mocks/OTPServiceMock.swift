@testable import Passwords
import Foundation


final class OTPServiceMock: OTPServiceProtocol, Mock, FunctionCallLogging {
    
    var _makeOtp: OTP? // swiftlint:disable:this identifier_name
    func makeOtp(type: OTP.OTPType, algorithm: Crypto.OTP.Algorithm?, secret: String, digits: Int?, counter: Int?, period: Int?) -> OTP? {
        logFunctionCall(parameters: type, algorithm, secret, digits, counter, period)
        return _makeOtp
    }
    
    func makeOtp(urlString: String) -> OTP? {
        logFunctionCall(parameters: urlString)
        return _makeOtp
    }
    
    var _hasDefaults = false // swiftlint:disable:this identifier_name
    func hasDefaults(otp: OTP) -> Bool {
        logFunctionCall(parameters: otp)
        return _hasDefaults
    }
    
    var _otpUrl: URL? // swiftlint:disable:this identifier_name
    func otpUrl(type: OTP.OTPType, algorithm: Crypto.OTP.Algorithm?, secret: String, digits: Int?, counter: Int?, period: Int?, issuer: String?, accountname: String?) -> URL? {
        logFunctionCall(parameters: type, algorithm, secret, digits, counter, period, issuer, accountname)
        return _otpUrl
    }
    
}
