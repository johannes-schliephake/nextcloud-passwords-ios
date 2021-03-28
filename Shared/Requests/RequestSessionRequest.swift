import Foundation


struct RequestSessionRequest {
    
    let session: Session
    
}


extension RequestSessionRequest: NCPasswordsRequest {
    
    var requiresSession: Bool {
        false
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        get(action: "session/request", session: session, completion: completion)
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
