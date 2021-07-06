import Foundation


struct UpdatePasswordRequest {
    
    let session: Session
    let password: Password
    
}


extension UpdatePasswordRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.updatingJsonEncoder.encode(password)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        patch(action: "password/update", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? Configuration.jsonDecoder.decode(Response.self, from: data)
    }
    
}


extension UpdatePasswordRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
