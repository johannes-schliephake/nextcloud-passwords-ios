import Foundation


struct RequestSessionRequest {
    
    let credentials: Credentials
    
}


extension RequestSessionRequest: NCPasswordsRequest {
    
    func send(completion: @escaping (Response?) -> Void) {
        get(action: "session/request", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension RequestSessionRequest {
    
    struct Response: Decodable {
        
        let challenge: Crypto.PWDv1r1.Challenge?
        
    }
    
}
