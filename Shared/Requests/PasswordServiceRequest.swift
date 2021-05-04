import Foundation


struct PasswordServiceRequest {
    
    let session: Session
    let numbers: Bool
    let special: Bool
    
}


extension PasswordServiceRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try JSONEncoder().encode(Request(strength: 4, numbers: numbers, special: special))
    }
    
    func send(completion: @escaping (String?) -> Void) {
        post(action: "service/password", session: session, completion: completion)
    }
    
    func decode(data: Data) -> String? {
        try? JSONDecoder().decode(Response.self, from: data).password
    }
    
}


extension PasswordServiceRequest {
    
    struct Request: Encodable {
        
        let strength: Int
        let numbers: Bool
        let special: Bool
        
    }
    
}


extension PasswordServiceRequest {
    
    struct Response: Decodable {
        
        let password: String
        let words: [String]
        let strength: Int
        let numbers: Bool
        let special: Bool
        
    }
    
}
