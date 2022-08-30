import Foundation
import Combine


struct DeleteAppPasswordOCSRequest {
    
    let session: Session
    
}


extension DeleteAppPasswordOCSRequest {
    
    var publisher: AnyPublisher<Void, URLError> {
        guard !session.hasAppPassword else {
            return Just(())
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }
        guard let authorizationData = "\(session.user):\(session.password)".data(using: .utf8) else {
            return Fail(error: URLError(.userAuthenticationRequired))
                .eraseToAnyPublisher()
        }
        guard let serverUrl = URL(string: session.server) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        let url = serverUrl.appendingPathComponent("ocs/v2.php/core/apppassword")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("true", forHTTPHeaderField: "OCS-APIREQUEST")
        request.setValue("Basic \(authorizationData.base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        return NetworkClient.default.dataTaskPublisher(for: request)
            .retry(1)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
}
