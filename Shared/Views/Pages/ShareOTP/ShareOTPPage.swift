import SwiftUI


struct ShareOTPPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<ShareOTPViewModel>
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
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
    }
    
    private func qrCode() -> some View {
        HStack {
            Spacer()
            if let qrCode = viewModel[\.qrCode] {
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: horizontalSizeClass == .compact && verticalSizeClass == .regular ? .infinity : 240)
                    .padding(.vertical)
            } else {
                ProgressView()
            }
            Spacer()
        }
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
