import SwiftUI
import AVFoundation


struct CaptureOTPPage: View {
    
    let capture: (OTP) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showErrorAlert = false
    @State private var isTorchActive = false
    
    // MARK: Views
    
    var body: some View {
        mainStack()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("_scanQrCode")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    if let videoCaptureDevice = AVCaptureDevice.default(for: .video),
                       videoCaptureDevice.hasTorch,
                       videoCaptureDevice.isTorchAvailable {
                        torchToggle(videoCaptureDevice: videoCaptureDevice)
                    }
                }
            }
    }
    
    private func mainStack() -> some View {
        GeometryReader {
            geometryProxy in
            ZStack {
                QRCapture(extract: extractCapture, finish: finishCapture)
                    .background(Color.black)
                    .alert(isPresented: $showErrorAlert) {
                        Alert(title: Text("_error"), message: Text("_qrCaptureErrorMessage"), dismissButton: .cancel {
                            dismiss()
                        })
                    }
                let sideLength = min(geometryProxy.size.width, geometryProxy.size.height) * 0.8
                Rectangle()
                    .strokeBorder(.yellow, lineWidth: 1.5)
                    .frame(width: sideLength, height: sideLength)
                    .padding(.bottom, geometryProxy.safeAreaInsets.bottom)
            }
            .edgesIgnoringSafeArea([.horizontal, .bottom])
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel", role: .cancel) {
            dismiss()
        }
    }
    
    private func torchToggle(videoCaptureDevice: AVCaptureDevice) -> some View {
        Button {
            toggleTorch(videoCaptureDevice: videoCaptureDevice)
        }
        label: {
            Image(systemName: isTorchActive ? "lightbulb.fill" : "lightbulb")
        }
        .onReceive(videoCaptureDevice.publisher(for: \.isTorchActive)) { isTorchActive = $0 }
    }
    
    // MARK: Functions
    
    private func extractCapture(_ captured: String) -> OTP? {
        guard let url = URL(string: captured) else {
            return nil
        }
        return OTP(from: url)
    }
    
    private func finishCapture(_ otp: OTP?) {
        guard let otp else {
            showErrorAlert = true
            return
        }
        capture(otp)
        dismiss()
    }
    
    private func toggleTorch(videoCaptureDevice: AVCaptureDevice) {
        guard (try? videoCaptureDevice.lockForConfiguration()) != nil else {
            return
        }
        videoCaptureDevice.torchMode = videoCaptureDevice.isTorchActive ? .off : .on
        videoCaptureDevice.unlockForConfiguration()
    }
    
}


struct CaptureOTPPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                CaptureOTPPage(capture: { _ in })
            }
            .showColumns(false)
        }
    }
    
}
