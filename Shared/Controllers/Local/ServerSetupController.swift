import Foundation


final class ServerSetupController: ObservableObject {
    
    @Published private(set) var isValidating = false
    @Published private(set) var validServerUrl: URL?
    @Published var serverAddress = "https://" {
        didSet {
            validServerUrl = nil
            isValidating = false
            guard let url = URL(string: serverAddress),
                  url.host != nil,
                  url.scheme?.lowercased() == "https" else {
                return
            }
            isValidating = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                [weak self] in
                guard let serverAddress = self?.serverAddress,
                      URL(string: serverAddress) == url else {
                    return
                }
                
                /// Check if url hosts a Nextcloud instance 1.5 seconds after last user input
                AuthenticationChallengeController.default.clearAcceptedCertificateHash()
                let capabilitiesUrl = url.appendingPathComponent("ocs/v1.php/cloud/capabilities")
                var request = URLRequest(url: capabilitiesUrl)
                request.addValue("true", forHTTPHeaderField: "OCS-APIREQUEST")
                
                URLSession(configuration: .default, delegate: AuthenticationChallengeController.default, delegateQueue: .main).dataTask(with: request) {
                    data, _, _ in
                    guard let serverAddress = self?.serverAddress,
                          URL(string: serverAddress) == url else {
                        return
                    }
                    self?.isValidating = false
                    
                    guard let data = data,
                          let body = String(data: data, encoding: .utf8),
                          body.hasPrefix("<?xml version=\"1.0\"?>\n<ocs>") else {
                        return
                    }
                    self?.validServerUrl = url
                }
                .resume()
            }
        }
    }
    
}
