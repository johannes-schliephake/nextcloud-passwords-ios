import Foundation


struct CloseSessionRequest {
    
    let credentials: Credentials
    
}


extension CloseSessionRequest: NCPasswordsRequest {
    
    func send(completion: @escaping (Response?) -> Void) {
        get(action: "session/close", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension CloseSessionRequest {
    
    struct Response: Decodable {
        
        let success: Bool
        
    }
    
}
