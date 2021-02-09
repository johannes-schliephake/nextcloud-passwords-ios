import CryptoKit
import WebKit
import Combine


final class AuthenticationChallengeController: NSObject, ObservableObject {
    
    static let `default` = AuthenticationChallengeController()
    
    @Published var certificateConfirmationRequests = [CertificateConfirmationRequest]()
    
    private var acceptedCertificateHash: String? {
        didSet {
            guard let acceptedCertificateHash = acceptedCertificateHash else {
                keychain.remove(key: "acceptedCertificateHash")
                return
            }
            keychain.store(key: "acceptedCertificateHash", value: acceptedCertificateHash)
        }
    }
    private var subscriptions = Set<AnyCancellable>()
    
    private let keychain = Keychain(service: Bundle.main.object(forInfoDictionaryKey: "AppService") as! String, accessGroup: Bundle.main.object(forInfoDictionaryKey: "AppKeychain") as! String)
    
    override init() {
        super.init()
        
        acceptedCertificateHash = keychain.load(key: "acceptedCertificateHash")
        CredentialsController.default.$credentials.sink(receiveValue: clearAcceptedCertificateHash).store(in: &subscriptions)
    }
    
    func clearAcceptedCertificateHash(credentials: Credentials? = nil) {
        guard credentials == nil else {
            return
        }
        acceptedCertificateHash = nil
    }
    
    func accept(certificateHash: String) {
        acceptedCertificateHash = certificateHash
        
        let acceptedCertificateConfirmationRequests = certificateConfirmationRequests.filter { $0.hash == certificateHash }
        certificateConfirmationRequests.removeAll { acceptedCertificateConfirmationRequests.contains($0) }
        acceptedCertificateConfirmationRequests.forEach { $0.accept() }
    }
    
    func deny(certificateHash: String) {
        CredentialsController.default.logout()
        
        let deniedCertificateConfirmationRequests = certificateConfirmationRequests.filter { $0.hash == certificateHash }
        certificateConfirmationRequests.removeAll { deniedCertificateConfirmationRequests.contains($0) }
        deniedCertificateConfirmationRequests.forEach { $0.deny() }
    }
    
    private func handler(didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        /// Check certificate and calculate SHA-256 if invalid
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        if SecTrustEvaluateWithError(serverTrust, nil) {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let certificateData = SecCertificateCopyData(certificate) as Data
        let certificateHash = SHA256.hash(data: certificateData).map { String(format: "%02X", $0) }.joined(separator: ":")
        
        /// Check certificate hash against accepted hash
        if certificateHash == acceptedCertificateHash {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }
        
        /// Add data needed for certificate confirmation
        let certificateConfirmationRequest = CertificateConfirmationRequest(hash: certificateHash, accept: {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }, deny: {
            completionHandler(.performDefaultHandling, nil)
        })
        certificateConfirmationRequests.append(certificateConfirmationRequest)
    }
    
}


extension AuthenticationChallengeController {
    
    struct CertificateConfirmationRequest: Identifiable, Equatable {
        
        let id = UUID()
        let hash: String
        let accept: () -> Void
        let deny: () -> Void
        
        static func ==(lhs: CertificateConfirmationRequest, rhs: CertificateConfirmationRequest) -> Bool {
            lhs.id == rhs.id
        }
        
    }
    
}


extension AuthenticationChallengeController: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        handler(didReceive: challenge, completionHandler: completionHandler)
    }
    
}


extension AuthenticationChallengeController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        handler(didReceive: challenge, completionHandler: completionHandler)
    }
    
}
