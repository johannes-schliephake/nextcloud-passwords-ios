import Foundation


struct CreateTagRequest {
    
    let session: Session
    let tag: Tag
    
}


extension CreateTagRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.updatingJsonEncoder.encode(tag)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        post(action: "tag/create", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? Configuration.jsonDecoder.decode(Response.self, from: data)
    }
    
}


extension CreateTagRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
