import Foundation


struct CloseSessionRequest {
    
    let session: Session
    
}


extension CloseSessionRequest: NCPasswordsRequest {
    
    var requiresSession: Bool {
        false
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        get(action: "session/close", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? Configuration.jsonDecoder.decode(Response.self, from: data)
    }
    
}


extension CloseSessionRequest {
    
    struct Response: Decodable {
        
        let success: Bool
        
    }
    
}
