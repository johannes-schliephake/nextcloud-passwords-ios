import Foundation
import Combine


final class ServerSetupController: ObservableObject {
    
    @Published private(set) var isValidating = false
    @Published private(set) var response: Response?
    @Published var serverAddress = ""
    @Published private(set) var serverUrlIsManaged = false
    @Published var showManagedServerUrlErrorAlert = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $serverAddress
            .dropFirst()
            .removeDuplicates()
            .handleEvents(receiveOutput: {
                [weak self] _ in
                self?.response = nil
                self?.isValidating = false
            })
            .compactMap {
                [weak self] serverAddress -> URL? in
                guard let url = URL(string: serverAddress),
                      url.host != nil,
                      url.scheme?.lowercased() == "https" else {
                    self?.showManagedServerUrlErrorAlert = self?.serverUrlIsManaged == true
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
                url in
                let loginFlowUrl = url.appendingPathComponent("index.php/login/v2")
                var request = URLRequest(url: loginFlowUrl)
                request.httpMethod = "POST"
                return request
            }
            .flatMap {
                [weak self] request in
                NetworkClient.default.dataTaskPublisher(for: request)
                    .compactMap {
                        [weak self] result in
                        guard let serverAddress = self?.serverAddress,
                              let testUrl = URL(string: serverAddress)?.appendingPathComponent("index.php/login/v2"),
                              testUrl == result.response.url else {
                            return nil
                        }
                        return result.data
                    }
                    .decode(type: Response?.self, decoder: Configuration.jsonDecoder)
                    .handleEvents(receiveCompletion: {
                        [weak self] completion in
                        guard case .failure(let error) = completion else {
                            return
                        }
                        DispatchQueue.main.async {
                            self?.showManagedServerUrlErrorAlert = self?.serverUrlIsManaged == true
                        }
                        guard error is DecodingError else {
                            return
                        }
                        LoggingController.shared.log(error: error)
                    })
                    .replaceError(with: nil)
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: {
                [weak self] _ in
                self?.isValidating = false
            })
            .compactMap { $0 }
            .sink { [weak self] in self?.response = $0 }
            .store(in: &subscriptions)
        
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .map { _ in }
            .prepend(())
            .map { UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed")?["serverUrl"] as? String }
            .removeDuplicates()
            .handleEvents(receiveOutput: {
                [weak self] serverAddress in
                self?.serverUrlIsManaged = serverAddress != nil
            })
            .sink { [weak self] in self?.serverAddress = $0 ?? "https://" }
            .store(in: &subscriptions)
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
