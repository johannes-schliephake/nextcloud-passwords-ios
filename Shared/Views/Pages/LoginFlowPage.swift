import SwiftUI
import WebKit


struct LoginFlowPage: View {
    
    let serverSetupResponse: ServerSetupController.Response
    
    // MARK: Views
    
    var body: some View {
        webView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("_logIn")
            .interactiveDismissDisabled()
    }
    
    private func webView() -> some View {
        LoginFlowWebView(serverSetupResponse: serverSetupResponse)
            .edgesIgnoringSafeArea(.bottom)
    }
    
}


extension LoginFlowPage {
    
    private struct LoginFlowWebView: UIViewRepresentable {
        
        private let loginUrl: URL
        private let loginFlowNavigationController: LoginFlowNavigationController
        
        init(serverSetupResponse: ServerSetupController.Response) {
            self.loginUrl = serverSetupResponse.login
            loginFlowNavigationController = LoginFlowNavigationController(poll: serverSetupResponse.poll)
        }
        
        func makeUIView(context: Context) -> BottomlessWKWebView {
            let configuration = WKWebViewConfiguration()
            configuration.websiteDataStore = .nonPersistent()
            let webView = BottomlessWKWebView(frame: .zero, configuration: configuration)
            webView.isOpaque = false
            webView.navigationDelegate = loginFlowNavigationController
            webView.customUserAgent = Configuration.clientName
            
            var request = URLRequest(url: loginUrl)
            if let language = NSLocale.preferredLanguages.first {
                request.addValue(language, forHTTPHeaderField: "Accept-Language")
            }
            webView.load(request)
            
            return webView
        }
        
        func updateUIView(_: BottomlessWKWebView, context: Context) {}
        
    }
    
}


extension LoginFlowPage {
    
    final class BottomlessWKWebView: WKWebView { /// Funny, right?
        
        override var safeAreaInsets: UIEdgeInsets {
            var edgeInsets = super.safeAreaInsets
            edgeInsets.bottom = 0
            return edgeInsets
        }
        
    }
    
}


struct LoginFlowPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                LoginFlowPage(serverSetupResponse: ServerSetupController.Response.mock)
            }
            .showColumns(false)
        }
    }
    
}
