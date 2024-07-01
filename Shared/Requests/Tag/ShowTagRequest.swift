import Foundation


struct ShowTagRequest {
    
    let session: Session
    let id: String
    
}


extension ShowTagRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.nonUpdatingJsonEncoder.encode(Request(id: id))
    }
    
    func send(completion: @escaping (Tag?) -> Void) {
        post(action: "tag/show", session: session, completion: completion)
    }
    
    func decode(data: Data) throws -> Tag? {
        try Configuration.jsonDecoder.decode(Tag.self, from: data)
    }
    
}


extension ShowTagRequest {
    
    struct Request: Encodable {
        
        let id: String
        
    }
    
}
