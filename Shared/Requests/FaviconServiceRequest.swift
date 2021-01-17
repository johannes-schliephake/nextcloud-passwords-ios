import SwiftUI


struct FaviconServiceRequest {
    
    let credentials: Credentials
    let domain: String
    
}


extension FaviconServiceRequest: NCPasswordsRequest {
    
    func send(completion: @escaping (UIImage?) -> Void) {
        get(action: "service/favicon/\(domain)/\(Int(64 * UIScreen.main.scale))", credentials: credentials, completion: completion)
    }
    
    func decode(data: Data) -> UIImage? {
        UIImage(data: data)
    }
    
}
