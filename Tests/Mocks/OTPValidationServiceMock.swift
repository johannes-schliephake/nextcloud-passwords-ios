@testable import Passwords


final class OTPValidationServiceMock: OTPValidationServiceProtocol, Mock, FunctionCallLogging {
    
    var _validate = false // swiftlint:disable:this identifier_name
    func validate(type: OTP.OTPType, secret: String, digits: Int, counter: Int, period: Int) -> Bool {
        logFunctionCall(parameters: type, secret, digits, counter, period)
        return _validate
    }
    
}
