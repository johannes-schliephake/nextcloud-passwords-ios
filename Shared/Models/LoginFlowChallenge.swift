import Foundation


struct LoginFlowChallenge: Decodable {
    
    let login: URL
    let poll: Poll
    
    struct Poll: Decodable {
        
        let token: String
        let endpoint: URL
        
    }
    
}
