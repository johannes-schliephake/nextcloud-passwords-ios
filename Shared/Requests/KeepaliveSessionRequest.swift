import Foundation


struct KeepaliveSessionRequest {
    
    let credentials: Credentials
    
}


extension KeepaliveSessionRequest: NCPasswordsRequest {
    
    func send(completion: @escaping (Response?) -> Void) {
        get(action: "session/keepalive", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension KeepaliveSessionRequest {
    
    struct Response: Decodable {
        
        let success: Bool
        
    }
    
}
