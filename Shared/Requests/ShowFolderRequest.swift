import Foundation


struct ShowFolderRequest {
    
    let session: Session
    let id: String
    
}


extension ShowFolderRequest: NCPasswordsRequest {
    
    func encode() throws -> Data? {
        try Configuration.nonUpdatingJsonEncoder.encode(Request(id: id))
    }
    
    func send(completion: @escaping (Folder?) -> Void) {
        post(action: "folder/show", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Folder? {
        try? Configuration.jsonDecoder.decode(Folder.self, from: data)
    }
    
}


extension ShowFolderRequest {
    
    struct Request: Encodable {
        
        let id: String
        
    }
    
}
