import Foundation
import Combine


final class ServerSetupController: ObservableObject {
    
    @Published private(set) var isValidating = false
    @Published private(set) var response: Response?
    @Published var serverAddress = "https://" {
        didSet {
            response = nil
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
                
                AuthenticationChallengeController.default.clearAcceptedCertificateHash()
                let loginFlowUrl = url.appendingPathComponent("index.php/login/v2")
                var request = URLRequest(url: loginFlowUrl)
                request.httpMethod = "POST"
                
                NetworkClient.default.dataTask(with: request) {
                    data, _, _ in
                    guard let serverAddress = self?.serverAddress,
                          URL(string: serverAddress) == url else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.isValidating = false
                    }
                    
                    guard let data = data,
                          let response = try? Configuration.jsonDecoder.decode(Response.self, from: data) else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.response = response
                    }
                }
                .resume()
            }
        }
    }
    
}


extension ServerSetupController {
    
    struct Response: Decodable, MockObject {
        
        let poll: Poll
        let login: URL
        
        struct Poll: Decodable { // swiftlint:disable:this nesting
            
            let token: String
            let endpoint: URL
            
        }
        
        static var mock: Response {
            Response(poll: ServerSetupController.Response.Poll(token: "", endpoint: URL(string: "https://example.com")!), login: URL(string: "https://example.com")!)
        }
        
    }
    
}
