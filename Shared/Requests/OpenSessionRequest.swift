import Foundation


struct OpenSessionRequest {
    
    let credentials: Credentials
    let solution: String?
    
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
        
        let challenge: String?
        
    }
    
}


extension OpenSessionRequest {
    
    struct Response: Decodable {
        
        let success: Bool
        let keys: [String: String]
        
        /// Manually decode to account for empty keys dictionary being sent as empty array
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            success = try container.decode(Bool.self, forKey: .success)
            keys = (try? container.decode([String: String].self, forKey: .keys)) ?? [:]
        }
        
        enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case success
            case keys
        }
        
    }
    
}
