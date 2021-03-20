import Foundation


struct UpdatePasswordRequest {
    
    let credentials: Credentials
    let password: Password
    
}


extension UpdatePasswordRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try JSONEncoder().encode(password)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        patch(action: "password/update", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension UpdatePasswordRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
