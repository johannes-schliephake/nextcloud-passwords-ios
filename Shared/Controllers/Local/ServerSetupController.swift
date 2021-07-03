import Foundation
import Combine


final class ServerSetupController: ObservableObject {
    
    @Published private(set) var isValidating = false
    @Published private(set) var response: Response?
    @Published var serverAddress = "https://"
    
    init() {
        $serverAddress
            .handleEvents(receiveOutput: {
                [weak self] _ in
                self?.response = nil
                self?.isValidating = false
            })
            .compactMap {
                serverAddress -> URL? in
                guard let url = URL(string: serverAddress),
                      url.host != nil,
                      url.scheme?.lowercased() == "https" else {
                    return nil
                }
                return url
            }
            .handleEvents(receiveOutput: {
                [weak self] _ in
                self?.isValidating = true
            })
            .debounce(for: 1.5, scheduler: DispatchQueue.global(qos: .userInitiated))
            .handleEvents(receiveOutput: {
                _ in
                AuthenticationChallengeController.default.clearAcceptedCertificateHash()
            })
            .map {
                url -> URLRequest in
                let loginFlowUrl = url.appendingPathComponent("index.php/login/v2")
                var request = URLRequest(url: loginFlowUrl)
                request.httpMethod = "POST"
                return request
            }
            .flatMap {
                [weak self] request in
                NetworkClient.default.dataTaskPublisher(for: request)
                    .compactMap {
                        [weak self] result -> Data? in
                        guard let serverAddress = self?.serverAddress,
                              let testUrl = URL(string: serverAddress)?.appendingPathComponent("index.php/login/v2"),
                              testUrl == result.response.url else {
                            return nil
                        }
                        return result.data
                    }
                    .decode(type: Response?.self, decoder: Configuration.jsonDecoder)
                    .replaceError(with: nil)
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: {
                [weak self] _ in
                self?.isValidating = false
            })
            .compactMap { $0 }
            .assign(to: &$response)
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
