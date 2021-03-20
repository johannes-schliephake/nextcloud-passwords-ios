import Foundation


struct CreateFolderRequest {
    
    let credentials: Credentials
    let folder: Folder
    
}


extension CreateFolderRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try JSONEncoder().encode(folder)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        post(action: "folder/create", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> Response? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}


extension CreateFolderRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
