import Combine
import Factory


protocol TorchServiceProtocol {
    
    var isTorchAvailable: AnyPublisher<Bool, Never> { get }
    var isTorchActive: AnyPublisher<Bool, Never> { get }
    
    func toggleTorch() throws
    
}


enum TorchError: Error {
    case unsupported
    case failedToAccessHardware
}


struct TorchService: TorchServiceProtocol {
    
    @Injected(\.videoCapturer) private var videoCapturer
    
    var isTorchAvailable: AnyPublisher<Bool, Never> {
        videoCapturer.map(\.isTorchAvailablePublisher) ?? Just(false).eraseToAnyPublisher()
    }
    
    var isTorchActive: AnyPublisher<Bool, Never> {
        videoCapturer.map(\.isTorchActivePublisher) ?? Just(false).eraseToAnyPublisher()
    }
    
    func toggleTorch() throws {
        guard let videoCapturer else {
            throw TorchError.unsupported
        }
        
        let toggledTorchMode = videoCapturer.torchMode.toggled()
        guard videoCapturer.isTorchModeSupported(toggledTorchMode) else {
            throw TorchError.unsupported
        }
        
        do {
            try videoCapturer.lockForConfiguration()
        } catch {
            throw TorchError.failedToAccessHardware
        }
        defer { videoCapturer.unlockForConfiguration() }
        
        videoCapturer.torchMode = toggledTorchMode
    }
    
}
