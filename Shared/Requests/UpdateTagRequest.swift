import Foundation


struct UpdateTagRequest {
    
    let session: Session
    let tag: Tag
    
}


extension UpdateTagRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.updatingJsonEncoder.encode(tag)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        patch(action: "tag/update", session: session, completion: completion)
    }
    
    func decode(data: Data) throws -> Response? {
        try Configuration.jsonDecoder.decode(Response.self, from: data)
    }
    
}


extension UpdateTagRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
