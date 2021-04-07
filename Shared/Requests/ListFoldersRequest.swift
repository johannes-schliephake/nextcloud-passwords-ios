import Foundation


struct ListFoldersRequest {
    
    let session: Session
    
}


extension ListFoldersRequest: NCPasswordsRequest {
    
    func send(completion: @escaping ([Folder]?) -> Void) {
        get(action: "folder/list", session: session, completion: completion)
    }
    
    func decode(data: Data) -> [Folder]? {
        try? JSONDecoder().decode([Folder].self, from: data)
    }
    
}
