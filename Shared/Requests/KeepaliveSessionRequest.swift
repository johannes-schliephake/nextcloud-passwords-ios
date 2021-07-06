import Foundation


struct KeepaliveSessionRequest {
    
    let session: Session
    
}


extension KeepaliveSessionRequest: NCPasswordsRequest {
    
    var requiresSession: Bool {
        false
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        get(action: "session/keepalive", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? Configuration.jsonDecoder.decode(Response.self, from: data)
    }
    
}


extension KeepaliveSessionRequest {
    
    struct Response: Decodable {
        
        let success: Bool
        
    }
    
}
