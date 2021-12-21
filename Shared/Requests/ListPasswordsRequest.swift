import Foundation


struct ListPasswordsRequest {
    
    let session: Session
    
}


extension ListPasswordsRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.nonUpdatingJsonEncoder.encode(Request(details: "model+tag-ids"))
    }
    
    func send(completion: @escaping ([Password]?) -> Void) {
        post(action: "password/list", session: session, completion: completion)
    }
    
    func decode(data: Data) -> [Password]? {
        try? Configuration.jsonDecoder.decode([Password].self, from: data)
    }
    
}


extension ListPasswordsRequest {
    
    struct Request: Encodable {
        
        let details: String
        
    }
    
}
