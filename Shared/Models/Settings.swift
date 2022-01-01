import Foundation


final class Settings {
    
    let userPasswordSecurityHash: Int?
    let userSessionLifetime: Int?
    
    private init() {
        userPasswordSecurityHash = nil
        userSessionLifetime = nil
    }
    
}


extension Settings: Codable {
    
    enum CodingKeys: String, CodingKey {
        case userPasswordSecurityHash = "user.password.security.hash"
        case userSessionLifetime = "user.session.lifetime"
    }
    
}


extension Settings: MockObject {
    
    static var mock: Settings {
        Settings()
    }
    
}
