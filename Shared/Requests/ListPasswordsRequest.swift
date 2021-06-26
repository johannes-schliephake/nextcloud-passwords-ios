import Foundation


struct ListPasswordsRequest {
    
    let session: Session
    
}


extension ListPasswordsRequest: NCPasswordsRequest {
    
    func send(completion: @escaping ([Password]?) -> Void) {
        get(action: "password/list", session: session, completion: completion)
    }
    
    func decode(data: Data) -> [Password]? {
        try? Configuration.jsonDecoder.decode([Password].self, from: data)
    }
    
}
