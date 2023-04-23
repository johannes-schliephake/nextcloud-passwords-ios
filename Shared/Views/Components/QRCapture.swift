import SwiftUI
import AVFoundation
import Combine


protocol QRCaptureViewDelegate: AnyObject {
    
    func didCapture(string: String, stopRunning: () -> Void)
    func didFail()
    
}


struct QRCapture<D>: UIViewRepresentable {
    
    let extract: (_ captured: String) -> D?
    let finish: (_ result: D?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(qrCapture: self)
    }
    
    func makeUIView(context: Context) -> QRCaptureView {
        QRCaptureView(delegate: context.coordinator)
    }
    
    func updateUIView(_: QRCaptureView, context: Context) {}
    
}


extension QRCapture {
    
    final class Coordinator: QRCaptureViewDelegate {
        
        private let qrCapture: QRCapture
        
        init(qrCapture: QRCapture) {
            self.qrCapture = qrCapture
        }
        
        func didCapture(string: String, stopRunning: () -> Void) {
            guard let data = qrCapture.extract(string) else {
                return
            }
            stopRunning()
            qrCapture.finish(data)
        }
        
        func didFail() {
            qrCapture.finish(nil)
        }
        
    }
    
}


extension QRCapture {
    
    final class QRCaptureView: UIView, AVCaptureMetadataOutputObjectsDelegate {
        
        weak var delegate: (any QRCaptureViewDelegate)?
        
        private let captureSession = AVCaptureSession()
        private var subscriptions = Set<AnyCancellable>()
        
        init(delegate: (any QRCaptureViewDelegate)?) {
            self.delegate = delegate
            super.init(frame: .zero)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
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
                delegate?.didFail()
                return
            }
            captureSession.addInput(videoInput)
            
            let metadataOutput = AVCaptureMetadataOutput()
            guard captureSession.canAddOutput(metadataOutput) else {
                delegate?.didFail()
                return
            }
            captureSession.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes = [.qr]
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            clipsToBounds = true
            layer.session = captureSession
            layer.videoGravity = .resizeAspectFill
            NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                .sink {
                    [weak self] _ in
                    self?.updateVideoOrientation()
                }
                .store(in: &subscriptions)
            updateVideoOrientation()
            
            captureSession.startRunning()
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = readableCode.stringValue else {
                return
            }
            delegate?.didCapture(string: value, stopRunning: {
                [weak self] in
                self?.captureSession.stopRunning()
            })
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
