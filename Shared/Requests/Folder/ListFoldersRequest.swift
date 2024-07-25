import Foundation


struct ListFoldersRequest {
    
    let session: Session
    
}


extension ListFoldersRequest: NCPasswordsRequest {
    
    func send(completion: @escaping ([Folder]?) -> Void) {
        get(action: "folder/list", session: session, completion: completion)
    }
    
    func decode(data: Data) throws -> [Folder]? {
        try Configuration.jsonDecoder.decode([Folder].self, from: data)
    }
    
}
