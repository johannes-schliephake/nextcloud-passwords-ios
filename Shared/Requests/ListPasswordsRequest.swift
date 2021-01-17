import Foundation


struct ListPasswordsRequest {
    
    let credentials: Credentials
    
}


extension ListPasswordsRequest: NCPasswordsRequest {
    
    func send(completion: @escaping ([Password]?) -> Void) {
        get(action: "password/list", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> [Password]? {
        try? JSONDecoder().decode([Password].self, from: data)
    }
    
}
