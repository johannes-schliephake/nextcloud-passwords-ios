import SwiftUI
import WebKit


struct WebView: UIViewRepresentable {
    
    @Binding private var request: URLRequest
    private let userAgent: String?
    private let dataStore: any WebDataStore
    private let checkTrust: ((SecTrust) async -> Bool)?
    
    init(request: Binding<URLRequest>, userAgent: String? = nil, dataStore: any WebDataStore = WKWebsiteDataStore.nonPersistent(), checkTrust: ((SecTrust) async -> Bool)? = nil) {
        _request = request
        self.userAgent = userAgent
        self.dataStore = dataStore
        self.checkTrust = checkTrust
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(webView: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        if let dataStore = dataStore as? WKWebsiteDataStore {
            configuration.websiteDataStore = dataStore
        } else {
            assertionFailure("WKWebView requires a data store of type WKWebsiteDataStore")
        }
        let webView = BottomlessWKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.customUserAgent = userAgent
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard request != context.coordinator.latestRequest else {
            return
        }
        context.coordinator.latestRequest = request
        webView.load(request)
    }
    
}


extension WebView {
    
    final class Coordinator: NSObject, WKNavigationDelegate {
        
        private let webView: WebView
        fileprivate(set) var latestRequest: URLRequest?
        
        init(webView: WebView) {
            self.webView = webView
        }
        
        func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
            guard navigationAction.targetFrame?.isMainFrame == true else {
                return
            }
            latestRequest = navigationAction.request
            webView.request = navigationAction.request
        }
        
        func webView(_: WKWebView, respondTo challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
            guard let trust = challenge.protectionSpace.serverTrust,
                  await webView.checkTrust?(trust) == true else {
                return (.performDefaultHandling, nil)
            }
            return (.useCredential, .init(trust: trust))
        }
        
    }
        
}


extension WebView {
    
    private final class BottomlessWKWebView: WKWebView { /// Funny, right?
        
        override var safeAreaInsets: UIEdgeInsets {
            var edgeInsets = super.safeAreaInsets
            edgeInsets.bottom = 0
            return edgeInsets
        }
        
    }
    
}
