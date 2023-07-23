import SwiftUI
import AVFoundation
import Combine


struct QRCapture: UIViewRepresentable {
    
    let action: (_ result: Result<String, Error>) -> Void
    
    func makeUIView(context: Context) -> QRCaptureView {
        QRCaptureView(action: action)
    }
    
    func updateUIView(_: QRCaptureView, context: Context) {}
    
    static func dismantleUIView(_ qrCaptureView: QRCaptureView, coordinator: Coordinator) {
        qrCaptureView.finish()
    }
    
}


extension QRCapture {
    
    final class QRCaptureView: UIView, AVCaptureMetadataOutputObjectsDelegate {
        
        private let action: (_ result: Result<String, Error>) -> Void
        
        private let captureSession = AVCaptureSession()
        private var cancellables = Set<AnyCancellable>()
        
        init(action: @escaping (_ result: Result<String, Error>) -> Void) {
            self.action = action
            super.init(frame: .zero)

            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented") // swiftlint:disable:this fatal_error
        }
        
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        override var layer: AVCaptureVideoPreviewLayer {
            super.layer as! AVCaptureVideoPreviewLayer // swiftlint:disable:this force_cast
        }
        
        func setup() {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
                  let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
                  captureSession.canAddInput(videoInput) else {
                action(.failure(AVError(.deviceNotConnected)))
                return
            }
            captureSession.addInput(videoInput)
            
            let metadataOutput = AVCaptureMetadataOutput()
            guard captureSession.canAddOutput(metadataOutput) else {
                action(.failure(AVError(.deviceNotConnected)))
                return
            }
            captureSession.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes = [.qr]
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            NotificationCenter.default.publisher(for: .AVCaptureSessionRuntimeError)
                .compactMap { $0.userInfo?[AVCaptureSessionErrorKey] as? AVError }
                .sink { [weak self] in self?.action(.failure($0)) }
                .store(in: &cancellables)
            
            clipsToBounds = true
            layer.session = captureSession
            layer.videoGravity = .resizeAspectFill
            NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                .sink { [weak self] _ in self?.updateVideoOrientation() }
                .store(in: &cancellables)
            updateVideoOrientation()
            
            DispatchQueue().async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
        
        func finish() {
            DispatchQueue().async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = readableCode.stringValue else {
                return
            }
            action(.success(value))
        }
        
        private func updateVideoOrientation() {
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                layer.connection?.videoOrientation = .landscapeRight
            case .landscapeRight:
                layer.connection?.videoOrientation = .landscapeLeft
            case .portraitUpsideDown:
                layer.connection?.videoOrientation = .portraitUpsideDown
            default:
                layer.connection?.videoOrientation = .portrait
            }
        }
        
    }
    
}
