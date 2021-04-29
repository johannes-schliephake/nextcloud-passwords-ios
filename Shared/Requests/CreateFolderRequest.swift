import Foundation


struct CreateFolderRequest {
    
    let session: Session
    let folder: Folder
    
}


extension CreateFolderRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        let encoder = JSONEncoder()
        encoder.userInfo[CodingUserInfoKey(rawValue: "updated")!] = true
        return try encoder.encode(folder)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        post(action: "folder/create", session: session, completion: completion)
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
