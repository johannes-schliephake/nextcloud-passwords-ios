import Foundation


struct UpdateFolderRequest {
    
    let credentials: Credentials
    let folder: Folder
    
}


extension UpdateFolderRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try JSONEncoder().encode(folder)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        patch(action: "folder/update", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension UpdateFolderRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
