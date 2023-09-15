@testable import Passwords
import CoreImage


final class QRCodeGeneratorMock: QRCodeGenerating, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    var _outputImage: CIImage? // swiftlint:disable:this identifier_name
    var outputImage: CIImage? {
        logPropertyAccess()
        return _outputImage
    }
    
    func setValue(_ value: Any?, forKey key: String) {
        logFunctionCall(parameters: value as? Data ?? String(describing: value), key)
    }
    
}
