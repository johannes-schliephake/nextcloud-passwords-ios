import SwiftUI
import AVFoundation


struct CaptureOTPPage: View {
    
    let capture: (OTP) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var sessionController: SessionController
    
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
            .onChange(of: sessionController.state) {
                state in
                if state.isChallengeAvailable {
                    presentationMode.wrappedValue.dismiss()
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
                            presentationMode.wrappedValue.dismiss()
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
    
    @ViewBuilder private func cancelButton() -> some View {
        if #available(iOS 15.0, *) {
            Button("_cancel", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        else {
            Button("_cancel") {
                presentationMode.wrappedValue.dismiss()
            }
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
    
    private func finishCapture(_ result: OTP?) {
        guard let otp = result else {
            showErrorAlert = true
            return
        }
        capture(otp)
        presentationMode.wrappedValue.dismiss()
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
