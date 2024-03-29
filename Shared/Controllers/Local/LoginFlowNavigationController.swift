import Combine
import Factory
import WebKit


final class LoginFlowNavigationController: NSObject {
    
    @LazyInjected(\.logger) private var logger
    
    private let poll: ServerSetupController.Response.Poll
    
    init(poll: ServerSetupController.Response.Poll) {
        self.poll = poll
        super.init()
    }
    
}


extension LoginFlowNavigationController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        guard let relativeReference = navigationAction.request.url?.relativeReference,
              relativeReference.hasSuffix("/login/v2/grant") || relativeReference.hasSuffix("/login/v2/apptoken") else {
            return
        }
        
        var request = URLRequest(url: poll.endpoint)
        request.httpMethod = "POST"
        request.httpBody = "token=\(poll.token)".data(using: .utf8)
        
        let sessionPublisher = NetworkClient.default.dataTaskPublisher(for: request)
            .tryMap {
                result in
                guard let response = result.response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    throw URLError(.userAuthenticationRequired)
                }
                return result.data
            }
            .decode(type: Response?.self, decoder: Configuration.jsonDecoder)
            .handleEvents(receiveCompletion: {
                [weak self] completion in
                guard case .failure(let error) = completion else {
                    return
                }
                self?.logger.log(error: error)
            })
            .catch {
                error in
                Fail(error: error)
                    .delay(for: 1, scheduler: DispatchQueue.global(qos: .utility))
            }
            .retry(30)
            .replaceError(with: nil)
            .compactMap { $0 }
            .map { Session(server: $0.server, user: $0.loginName, password: $0.appPassword) }
            .receive(on: DispatchQueue.main)
            .zip(Future<HTTPCookie?, Never> {
                promise in
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies {
                    cookies in
                    let flowSessionCookie = cookies.first { $0.name == "nc_session_id" }
                    promise(.success(flowSessionCookie))
                }
            })
            .map {
                appSession, flowSessionCookie in
                let webSession = flowSessionCookie.map { Session(server: appSession.server, user: appSession.user, password: $0.value) }
                return (appSession, webSession)
            }
            .flatMap {
                appSession, webSession in
                guard let webSession else {
                    return Just(appSession)
                        .eraseToAnyPublisher()
                }
                return DeleteAppPasswordOCSRequest(session: webSession).publisher
                    .replaceError(with: ())
                    .map { appSession }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        SessionController.default.attachSessionPublisher(sessionPublisher)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        AuthenticationChallengeController.default.webView(webView, didReceive: challenge, completionHandler: completionHandler)
    }
    
}


extension LoginFlowNavigationController {
    
    private struct Response: Decodable {
        
        let server: String
        let loginName: String
        let appPassword: String
        
    }
    
}
