import Foundation


struct DeleteTagRequest {
    
    let session: Session
    let tag: Tag
    
}


extension DeleteTagRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.updatingJsonEncoder.encode(tag)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        delete(action: "tag/delete", session: session, completion: completion)
    }
    
    func decode(data: Data) throws -> Response? {
        try Configuration.jsonDecoder.decode(Response.self, from: data)
    }
    
}


extension DeleteTagRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
