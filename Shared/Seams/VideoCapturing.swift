import Combine
import AVFoundation


protocol VideoCapturing: AnyObject {
    
    var hasTorch: Bool { get }
    var isTorchAvailablePublisher: AnyPublisher<Bool, Never> { get }
    var isTorchActivePublisher: AnyPublisher<Bool, Never> { get }
    var torchMode: AVCaptureDevice.TorchMode { get set }
    
    func isTorchModeSupported(_: AVCaptureDevice.TorchMode) -> Bool
    func lockForConfiguration() throws
    func unlockForConfiguration()
    
}


extension AVCaptureDevice: VideoCapturing {
    
    var isTorchAvailablePublisher: AnyPublisher<Bool, Never> {
        publisher(for: \.isTorchAvailable)
            .eraseToAnyPublisher()
    }
    
    var isTorchActivePublisher: AnyPublisher<Bool, Never> {
        publisher(for: \.isTorchActive)
            .eraseToAnyPublisher()
    }
    
}
