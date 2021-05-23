import Foundation


struct ShowPasswordRequest {
    
    let session: Session
    let id: String
    
}


extension ShowPasswordRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try JSONEncoder().encode(Request(id: id))
    }
    
    func send(completion: @escaping (Password?) -> Void) {
        post(action: "password/show", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Password? {
        try? JSONDecoder().decode(Password.self, from: data)
    }
    
}


extension ShowPasswordRequest {
    
    struct Request: Encodable {
        
        let id: String
        
    }
    
}
