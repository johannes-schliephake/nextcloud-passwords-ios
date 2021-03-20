import Foundation


struct OpenSessionRequest {
    
    let credentials: Credentials
    let solution: String
    
}


extension OpenSessionRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try JSONEncoder().encode(Request(challenge: solution))
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        post(action: "session/open", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension OpenSessionRequest {
    
    struct Request: Encodable {
        
        let challenge: String
        // TODO: token
        
    }
    
}


extension OpenSessionRequest {
    
    struct Response: Decodable {
        
        let success: Bool
        let keys: [String: String]?
        
    }
    
}
