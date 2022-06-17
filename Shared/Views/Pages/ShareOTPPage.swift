import SwiftUI


struct ShareOTPPage: View {
    
    let data: Data
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var qrCodeImage: UIImage?
    @State private var showShareSheet = false
    
    // MARK: Views
    
    var body: some View {
        listView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("_exportAsQrCode")
    }
    
    private func listView() -> some View {
        List {
            qrCode()
            warningLabel()
            shareButton()
        }
        .listStyle(.insetGrouped)
        .onAppear {
            generateQrCode()
        }
    }
    
    private func qrCode() -> some View {
        HStack {
            Spacer()
            if let qrCodeImage {
                Image(uiImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: horizontalSizeClass == .compact && verticalSizeClass == .regular ? .infinity : 240)
                    .padding(.vertical)
            }
            else {
                ProgressView()
            }
            Spacer()
        }
    }
    
    private func warningLabel() -> some View {
        Label("_shareOtpWarningMessage", systemImage: "exclamationmark.triangle")
            .foregroundColor(.red)
    }
    
    private func shareButton() -> some View {
        Button {
            showShareSheet = true
        }
        label: {
            Label("_shareQrCode", systemImage: "square.and.arrow.up")
        }
        .disabled(qrCodeImage == nil)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [qrCodeImage as Any, "_otp".localized])
        }
    }
    
    // MARK: Functions
    
    private func generateQrCode() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
                return
            }
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 8, y: 8)
            guard let ciImage = filter.outputImage?.transformed(by: transform),
                  let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
                return
            }
            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                qrCodeImage = uiImage
            }
        }
    }
    
}


struct QRCodePagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                ShareOTPPage(data: OTP.mock.url!.absoluteString.data(using: .utf8)!)
            }
            .showColumns(false)
        }
    }
    
}
