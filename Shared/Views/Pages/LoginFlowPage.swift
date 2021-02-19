import SwiftUI
import WebKit


struct LoginFlowPage: View {
    
    let serverUrl: URL
    
    // MARK: Views
    
    var body: some View {
        webView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("_logIn")
    }
    
    private func webView() -> some View {
        LoginFlowWebView(serverUrl: serverUrl)
            .edgesIgnoringSafeArea(.bottom)
    }
    
}


extension LoginFlowPage {
    
    struct LoginFlowWebView: UIViewRepresentable {
        
        let serverUrl: URL
        
        init(serverUrl: URL) {
            self.serverUrl = serverUrl
        }
        
        func makeUIView(context: Context) -> BottomlessWKWebView {
            let schemeHandler = NCSchemeHandler(perform: {
                server, user, password in
                CredentialsController.default.credentials = Credentials(server: server, user: user, password: password)
            })
            let configuration = WKWebViewConfiguration()
            configuration.setURLSchemeHandler(schemeHandler, forURLScheme: "nc")
            let webView = BottomlessWKWebView(frame: .zero, configuration: configuration)
            webView.customUserAgent = Configuration.clientName
            webView.isOpaque = false
            webView.navigationDelegate = AuthenticationChallengeController.default
            return webView
        }
        
        func updateUIView(_ webView: BottomlessWKWebView, context: Context) {
            guard let language = NSLocale.preferredLanguages.first else {
                return
            }
            
            let url = serverUrl.appendingPathComponent("index.php/login/flow")
            var request = URLRequest(url: url)
            request.addValue("true", forHTTPHeaderField: "OCS-APIREQUEST")
            request.addValue(language, forHTTPHeaderField: "Accept-Language")
            webView.load(request)
        }
        
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
                LoginFlowPage(serverUrl: URL(string: "https://example.com")!)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
}
