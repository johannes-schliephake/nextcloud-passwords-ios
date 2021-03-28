import Foundation


enum NetworkClient {
    
    static let `default` = URLSession(configuration: .default, delegate: AuthenticationChallengeController.default, delegateQueue: nil)
    
}
