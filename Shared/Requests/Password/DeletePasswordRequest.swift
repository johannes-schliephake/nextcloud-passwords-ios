import Foundation


struct DeletePasswordRequest {
    
    let session: Session
    let password: Password
    
}


extension DeletePasswordRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.updatingJsonEncoder.encode(password)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        delete(action: "password/delete", session: session, completion: completion)
    }
    
    func decode(data: Data) throws -> Response? {
        try Configuration.jsonDecoder.decode(Response.self, from: data)
    }
    
}


extension DeletePasswordRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
