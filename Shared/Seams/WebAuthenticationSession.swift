import AuthenticationServices


protocol WebAuthenticationSession { // swiftlint:disable:this file_types_order
    
    var window: (any Window)? { get set }
    
    init(url: URL, callbackURLScheme: String?, completionHandler: @escaping (URL?, (any Error)?) -> Void)
    
    func start() -> Bool
    func cancel()
    
}


final class WrappedASWebAuthenticationSession: ASWebAuthenticationSession, WebAuthenticationSession {
    
    private class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
        
        private let presentationAnchor: ASPresentationAnchor
        
        init(presentationAnchor: ASPresentationAnchor) {
            self.presentationAnchor = presentationAnchor
        }
        
        func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
            presentationAnchor
        }
        
    }
    
    var window: (any Window)? {
        get {
            presentationContextProvider?.presentationAnchor(for: self)
        }
        set {
            let presentationAnchor = newValue as? ASPresentationAnchor
            retainedPresentationContextProvider = presentationAnchor.map(PresentationContextProvider.init)
        }
    }
    
    private var retainedPresentationContextProvider: (any ASWebAuthenticationPresentationContextProviding)? {
        didSet {
            presentationContextProvider = retainedPresentationContextProvider
        }
    }
    
}
