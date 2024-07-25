import Foundation


enum NetworkClient {
    
    static let `default`: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["User-Agent": Configuration.clientName]
        return URLSession(configuration: configuration, delegate: AuthenticationChallengeController.default, delegateQueue: nil)
    }()
    
}
