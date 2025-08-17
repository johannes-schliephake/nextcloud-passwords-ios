import SwiftUI


struct LoginFlowPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<LoginFlowViewModel>
    
    var body: some View {
        webView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("_logIn")
            .apply { view in
                if #available(iOS 26, *) {
                    view
                        .toolbar {
                            if viewModel[\.isLoading] {
                                ToolbarItem(placement: .primaryAction) {
                                    ProgressView()
                                }
                                .sharedBackgroundVisibility(.hidden)
                            }
                        }
                } else {
                    view
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                if viewModel[\.isLoading] {
                                    ProgressView()
                                }
                            }
                        }
                }
            }
            .interactiveDismissDisabled()
    }
    
    private func webView() -> some View {
        WebView(request: $viewModel[\.request], userAgent: viewModel[\.userAgent], dataStore: viewModel[\.dataStore]) { isLoading in
            viewModel(.updateLoadingState(isLoading))
        } checkTrust: { trust in
            await viewModel(.checkTrust(trust), returning: \.$isTrusted) ?? false
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
}
