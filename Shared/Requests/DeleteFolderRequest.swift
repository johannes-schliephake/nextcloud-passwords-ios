import Foundation


struct DeleteFolderRequest {
    
    let credentials: Credentials
    let folder: Folder
    
}


extension DeleteFolderRequest: NCPasswordsRequest {
    
    func encode() -> Data? {
        try? JSONEncoder().encode(folder)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        delete(action: "folder/delete", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension DeleteFolderRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
