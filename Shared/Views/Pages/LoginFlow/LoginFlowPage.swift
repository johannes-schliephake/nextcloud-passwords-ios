import SwiftUI


struct LoginFlowPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<LoginFlowViewModel>
    
    var body: some View {
        webView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("_logIn")
            .interactiveDismissDisabled()
    }
    
    private func webView() -> some View {
        WebView(request: $viewModel[\.request], userAgent: viewModel[\.userAgent], dataStore: viewModel[\.dataStore]) { trust in
            await viewModel(.checkTrust(trust), returning: \.$isTrusted) ?? false
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
}


