import SwiftUI


struct ShareOTPPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<ShareOTPViewModel>
    
    var body: some View {
        listView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("_exportAsQrCode")
    }
    
    private func listView() -> some View {
        List {
            qrCode()
                .listRowBackground(Color.clear)
            Section {
                warningLabel()
                shareButton()
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func qrCode() -> some View {
        Group {
            if let qrCode = viewModel[\.qrCode] {
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 240)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                    }
            } else {
                ProgressView()
                    .frame(height: 240)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func warningLabel() -> some View {
        Label("_shareOtpWarningMessage", systemImage: "exclamationmark.triangle")
            .foregroundColor(.red)
    }
    
    @ViewBuilder private func shareButton() -> some View {
        let item = Image(uiImage: viewModel[\.qrCode] ?? UIImage())
        ShareLink("_shareQrCode", item: item, preview: SharePreview("_otp", image: item))
            .enabled(viewModel[\.qrCodeAvailable])
    }
    
}
