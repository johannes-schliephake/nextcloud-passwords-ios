import SwiftUI


struct CaptureOTPPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<CaptureOTPViewModel>
    
    var body: some View {
        mainStack()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("_scanQrCode")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    if viewModel[\.isTorchAvailable] {
                        torchToggle()
                    }
                }
            }
            .dismiss(on: viewModel[\.shouldDismiss])
    }
    
    private func mainStack() -> some View {
        GeometryReader { geometryProxy in
            ZStack {
                if #available(iOS 16, *),
                   DataScannerView.isSupported {
                    DataScannerView(.qr) { viewModel(.captureQrResult($0)) }
                } else {
                    QRCapture { viewModel(.captureQrResult($0)) }
                }
                let sideLength = min(geometryProxy.size.width, geometryProxy.size.height) * 0.8
                Rectangle()
                    .strokeBorder(viewModel[\.didCaptureOtp] ? .green : .yellow, lineWidth: 1.5)
                    .frame(width: sideLength, height: sideLength)
                    .padding(.bottom, geometryProxy.safeAreaInsets.bottom)
            }
            .background(Color.black)
            .edgesIgnoringSafeArea([.horizontal, .bottom])
            .alert(isPresented: $viewModel[\.showErrorAlert]) {
                Alert(title: Text("_error"), message: Text("_qrCaptureErrorMessage"), dismissButton: .cancel {
                    viewModel(.cancel)
                })
            }
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel", role: .cancel) {
            viewModel(.cancel)
        }
    }
    
    private func torchToggle() -> some View {
        Button {
            viewModel(.toggleTorch)
        } label: {
            Image(systemName: viewModel[\.isTorchActive] ? "lightbulb.fill" : "lightbulb")
        }
    }
    
}
