import Foundation


struct ListSettingsRequest {
    
    let session: Session
    
}


extension ListSettingsRequest: NCPasswordsRequest {
    
    var requiresSession: Bool {
        false
    }
    
    func send(completion: @escaping (Settings?) -> Void) {
        post(action: "settings/list", session: session, completion: completion)
    }
    
    func decode(data: Data) -> Settings? {
        try? Configuration.jsonDecoder.decode(Settings.self, from: data)
    }
    
}
