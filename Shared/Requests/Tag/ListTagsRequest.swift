import Foundation


struct ListTagsRequest {
    
    let session: Session
    
}


extension ListTagsRequest: NCPasswordsRequest {
    
    func send(completion: @escaping ([Tag]?) -> Void) {
        get(action: "tag/list", session: session, completion: completion)
    }
    
    func decode(data: Data) throws -> [Tag]? {
        try Configuration.jsonDecoder.decode([Tag].self, from: data)
    }
    
}
