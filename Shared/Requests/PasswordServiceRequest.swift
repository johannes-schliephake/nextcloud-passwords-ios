import Foundation


struct PasswordServiceRequest {
    
    let session: Session
    let strength: Strength
    let numbers: Bool
    let special: Bool
    
}


extension PasswordServiceRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.nonUpdatingJsonEncoder.encode(Request(strength: strength, numbers: numbers, special: special))
    }
    
    func send(completion: @escaping (String?) -> Void) {
        post(action: "service/password", session: session, completion: completion)
    }
    
    func decode(data: Data) -> String? {
        try? Configuration.jsonDecoder.decode(Response.self, from: data).password
    }
    
}


extension PasswordServiceRequest {
    
    enum Strength: Int, Codable, Identifiable, CaseIterable {
        
        case low
        case `default`
        case medium
        case high
        case ultra
        
        var id: Int {
            rawValue
        }
    }
    
}


extension PasswordServiceRequest {
    
    private struct Request: Encodable {
        
        let strength: Strength
        let numbers: Bool
        let special: Bool
        
    }
    
}


extension PasswordServiceRequest {
    
    struct Response: Decodable {
        
        let password: String
        let words: [String]
        let strength: Strength
        let numbers: Bool
        let special: Bool
        
    }
    
}
