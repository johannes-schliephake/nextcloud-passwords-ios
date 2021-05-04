import Foundation


struct DeleteFolderRequest {
    
    let session: Session
    let folder: Folder
    
}


extension DeleteFolderRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        let encoder = JSONEncoder()
        encoder.userInfo[CodingUserInfoKey(rawValue: "updated")!] = true
        return try encoder.encode(folder)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        delete(action: "folder/delete", session: session, completion: completion)
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
