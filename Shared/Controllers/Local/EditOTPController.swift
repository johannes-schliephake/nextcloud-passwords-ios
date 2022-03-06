import SwiftUI


final class EditOTPController: ObservableObject {
    
    let otp: OTP
    let updateOtp: (OTP?) -> Void
    
    @Published var otpType: OTP.OTPType
    @Published var otpAlgorithm: Crypto.OTP.Algorithm
    @Published var otpSecret: String
    @Published var otpDigits: Int
    @Published var otpCounter: Int
    @Published var otpPeriod: Int
    
    init(otp: OTP, updateOtp: @escaping (OTP?) -> Void) {
        self.otp = otp
        self.updateOtp = updateOtp
        otpType = otp.type
        otpAlgorithm = otp.algorithm
        otpSecret = otp.secret
        otpDigits = otp.digits
        otpCounter = otp.counter
        otpPeriod = otp.period
    }
    
    var hasChanges: Bool {
        otpType != otp.type ||
        otpAlgorithm != otp.algorithm ||
        otpSecret != otp.secret ||
        otpDigits != otp.digits ||
        otpType == .hotp && otpCounter != otp.counter ||
        otpType == .totp && otpPeriod != otp.period
    }
    
    var editIsValid: Bool {
        !otpSecret.isEmpty &&
        Data(base32Encoded: otpSecret) != nil &&
        6...8 ~= otpDigits &&
        (otpType == .hotp && otpCounter >= 0 || otpType == .totp && otpPeriod > 0)
    }
    
    func applyToOtp() {
        let otp = OTP(type: otpType, algorithm: otpAlgorithm, secret: otpSecret, digits: otpDigits, counter: otpType == .hotp ? otpCounter : nil, period: otpType == .totp ? otpPeriod : nil)
        updateOtp(otp)
    }
    
    func clearOtp() {
        updateOtp(nil)
    }
    
}
