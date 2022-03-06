import Foundation


struct OpenSessionRequest {
    
    let session: Session
    let solution: String?
    
}


extension OpenSessionRequest: NCPasswordsRequest {
    
    var requiresSession: Bool {
        false
    }
    
    func encode() throws -> Data? {
        try Configuration.nonUpdatingJsonEncoder.encode(Request(challenge: solution))
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        post(action: "session/open", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        if let response = try? Configuration.jsonDecoder.decode(Response.self, from: data) {
            return response
        }
        if let errorResponse = try? Configuration.jsonDecoder.decode(NCPasswordsRequestErrorResponse.self, from: data) {
            switch (errorResponse.status, errorResponse.id) {
            case ("error", "a361c427"): /// "Password invalid"
                return Response(success: false, keys: [:])
            default:
                break
            }
        }
        return nil
    }
    
}


extension OpenSessionRequest {
    
    private struct Request: Encodable {
        
        let challenge: String?
        
    }
    
}


extension OpenSessionRequest {
    
    struct Response: Decodable {
        
        let success: Bool
        let keys: [String: String]
        
        init(success: Bool, keys: [String: String]) {
            self.success = success
            self.keys = keys
        }
        
        /// Manually decode to account for empty keys dictionary being sent as empty array
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            success = try container.decode(Bool.self, forKey: .success)
            keys = (try? container.decode([String: String].self, forKey: .keys)) ?? [:]
        }
        
        private enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case success
            case keys
        }
        
    }
    
}
