import Foundation


struct UpdateFolderRequest {
    
    let session: Session
    let folder: Folder
    
}


extension UpdateFolderRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.updatingJsonEncoder.encode(folder)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        patch(action: "folder/update", session: session, completion: completion)
    }
    
    func decode(data: Data) throws -> Response? {
        try Configuration.jsonDecoder.decode(Response.self, from: data)
    }
    
}


extension UpdateFolderRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
