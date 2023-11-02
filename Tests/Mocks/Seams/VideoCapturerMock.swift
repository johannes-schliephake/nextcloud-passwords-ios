@testable import Passwords
import Combine
import AVFoundation


final class VideoCapturerMock: VideoCapturing, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    var _hasTorch = true // swiftlint:disable:this identifier_name
    var hasTorch: Bool {
        logPropertyAccess()
        return _hasTorch
    }
    
    let _isTorchAvailablePublisher = PassthroughSubject<Bool, Never>() // swiftlint:disable:this identifier_name
    var isTorchAvailablePublisher: AnyPublisher<Bool, Never> {
        logPropertyAccess()
        return _isTorchAvailablePublisher.eraseToAnyPublisher()
    }
    
    let _isTorchActivePublisher = PassthroughSubject<Bool, Never>() // swiftlint:disable:this identifier_name
    var isTorchActivePublisher: AnyPublisher<Bool, Never> {
        logPropertyAccess()
        return _isTorchActivePublisher.eraseToAnyPublisher()
    }
    
    var _torchMode: AVCaptureDevice.TorchMode = .off // swiftlint:disable:this identifier_name
    var torchMode: AVCaptureDevice.TorchMode {
        get {
            logPropertyAccess()
            return _torchMode
        }
        set {
            logPropertyAccess()
            _torchMode = newValue
        }
    }
    
    var _isTorchModeSupported = true // swiftlint:disable:this identifier_name
    func isTorchModeSupported(_ torchMode: AVCaptureDevice.TorchMode) -> Bool {
        logFunctionCall(parameters: String(describing: torchMode))
        return _isTorchModeSupported
    }
    
    var _lockForConfiguration: Result<Void, any Error> = .success(()) // swiftlint:disable:this identifier_name
    func lockForConfiguration() throws {
        logFunctionCall()
        try _lockForConfiguration.get()
    }
    
    func unlockForConfiguration() {
        logFunctionCall()
    }
    
}
