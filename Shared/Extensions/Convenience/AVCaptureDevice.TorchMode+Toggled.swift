import AVFoundation


extension AVCaptureDevice.TorchMode {
    
    func toggled() -> Self {
        self == .off ? .on : .off
    }
    
}
