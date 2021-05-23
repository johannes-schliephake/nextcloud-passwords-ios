import Foundation


struct ShowFolderRequest {
    
    let session: Session
    let id: String
    
}


extension ShowFolderRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try JSONEncoder().encode(Request(id: id))
    }
    
    func send(completion: @escaping (Folder?) -> Void) {
        post(action: "folder/show", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Folder? {
        try? JSONDecoder().decode(Folder.self, from: data)
    }
    
}


extension ShowFolderRequest {
    
    struct Request: Encodable {
        
        let id: String
        
    }
    
}
