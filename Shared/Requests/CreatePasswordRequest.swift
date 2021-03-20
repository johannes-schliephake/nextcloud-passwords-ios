import Foundation


struct CreatePasswordRequest {
    
    let credentials: Credentials
    let password: Password
    
}


extension CreatePasswordRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try JSONEncoder().encode(password)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        post(action: "password/create", credentials: credentials, completion: completion)
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
