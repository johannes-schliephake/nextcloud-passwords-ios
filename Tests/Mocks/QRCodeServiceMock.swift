@testable import Passwords
import Combine
import UIKit.UIImage


final class QRCodeServiceMock: QRCodeServiceProtocol, Mock, FunctionCallLogging {
    
    let _generateQrCode = PassthroughSubject<UIImage, QRCodeError>() // swiftlint:disable:this identifier_name
    func generateQrCode(from url: URL) -> AnyPublisher<UIImage, QRCodeError> {
        logFunctionCall(parameters: url)
        return _generateQrCode.eraseToAnyPublisher()
    }
    
}
