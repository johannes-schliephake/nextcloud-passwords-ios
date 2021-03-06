import SwiftUI
import WebKit


struct LoginFlowPage: View {
    
    let serverSetupResponse: ServerSetupController.Response
    
    // MARK: Views
    
    var body: some View {
        webView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("_logIn")
    }
    
    private func webView() -> some View {
        LoginFlowWebView(serverSetupResponse: serverSetupResponse)
            .edgesIgnoringSafeArea(.bottom)
    }
    
}


extension LoginFlowPage {
    
    struct LoginFlowWebView: UIViewRepresentable {
        
        private let loginUrl: URL
        private let loginFlowNavigationController: LoginFlowNavigationController
        
        init(serverSetupResponse: ServerSetupController.Response) {
            self.loginUrl = serverSetupResponse.login
            loginFlowNavigationController = LoginFlowNavigationController(poll: serverSetupResponse.poll)
        }
        
        func makeUIView(context: Context) -> BottomlessWKWebView {
            let webView = BottomlessWKWebView()
            webView.isOpaque = false
            webView.navigationDelegate = loginFlowNavigationController
            
            var request = URLRequest(url: loginUrl)
            if let language = NSLocale.preferredLanguages.first {
                request.addValue(language, forHTTPHeaderField: "Accept-Language")
            }
            webView.load(request)
            
            return webView
        }
        
        func updateUIView(_ webView: BottomlessWKWebView, context: Context) {}
        
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
