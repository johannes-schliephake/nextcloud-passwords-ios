import Foundation


struct ShowPasswordRequest {
    
    let session: Session
    let id: String
    
}


extension ShowPasswordRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.nonUpdatingJsonEncoder.encode(Request(id: id, details: "model+tag-ids"))
    }
    
    func send(completion: @escaping (Password?) -> Void) {
        post(action: "password/show", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Password? {
        try? Configuration.jsonDecoder.decode(Password.self, from: data)
    }
    
}


extension ShowPasswordRequest {
    
    private struct Request: Encodable {
        
        let id: String
        let details: String
        
    }
    
}
