import Foundation


struct CreatePasswordRequest {
    
    let session: Session
    let password: Password
    
}


extension CreatePasswordRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try JSONEncoder().encode(password)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        post(action: "password/create", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension CreatePasswordRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
