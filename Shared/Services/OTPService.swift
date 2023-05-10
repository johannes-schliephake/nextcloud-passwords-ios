import Foundation


protocol OTPServiceProtocol {
    
    func makeOtp(type: OTP.OTPType, algorithm: Crypto.OTP.Algorithm?, secret: String, digits: Int?, counter: Int?, period: Int?) -> OTP?
    func hasDefaults(otp: OTP) -> Bool
    func otpUrl(type: OTP.OTPType, algorithm: Crypto.OTP.Algorithm?, secret: String, digits: Int?, counter: Int?, period: Int?, issuer: String?, accountname: String?) -> URL?
    
}


struct OTPService: OTPServiceProtocol {
    
    func makeOtp(type: OTP.OTPType, algorithm: Crypto.OTP.Algorithm?, secret: String, digits: Int?, counter: Int?, period: Int?) -> OTP? {
        .init(type: type, algorithm: algorithm, secret: secret, digits: digits, counter: counter, period: period)
    }
    
    func hasDefaults(otp: OTP) -> Bool {
        otp.type == OTP.Defaults.type &&
        otp.algorithm == OTP.Defaults.algorithm &&
        otp.digits == OTP.Defaults.digits &&
        otp.period == OTP.Defaults.period
    }
    
    func otpUrl(type: OTP.OTPType, algorithm: Crypto.OTP.Algorithm?, secret: String, digits: Int?, counter: Int?, period: Int?, issuer: String?, accountname: String?) -> URL? {
        OTP(type: type, algorithm: algorithm, secret: secret, digits: digits, counter: counter, period: period, issuer: issuer, accountname: accountname)?.url
    }
    
}
