import Foundation


struct ListFoldersRequest {
    
    let credentials: Credentials
    
}


extension ListFoldersRequest: NCPasswordsRequest {
    
    func send(completion: @escaping ([Folder]?) -> Void) {
        get(action: "folder/list", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> [Folder]? {
        try? JSONDecoder().decode([Folder].self, from: data)
    }
    
}
