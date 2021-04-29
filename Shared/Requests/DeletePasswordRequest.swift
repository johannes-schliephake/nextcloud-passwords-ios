import Foundation


struct DeletePasswordRequest {
    
    let session: Session
    let password: Password
    
}


extension DeletePasswordRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        let encoder = JSONEncoder()
        encoder.userInfo[CodingUserInfoKey(rawValue: "updated")!] = true
        return try encoder.encode(password)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        delete(action: "password/delete", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension DeletePasswordRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
