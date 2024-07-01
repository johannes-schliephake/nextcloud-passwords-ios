import Foundation


struct CreateFolderRequest {
    
    let session: Session
    let folder: Folder
    
}


extension CreateFolderRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.updatingJsonEncoder.encode(folder)
    }
    
    func send(completion: @escaping (Response?) -> Void) {
        post(action: "folder/create", session: session, completion: completion)
    }
    
    func decode(data: Data) throws -> Response? {
        try Configuration.jsonDecoder.decode(Response.self, from: data)
    }
    
}


extension CreateFolderRequest {
    
    struct Response: Decodable {
        
        let id: String
        let revision: String
        
    }
    
}
