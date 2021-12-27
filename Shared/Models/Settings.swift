import Foundation


final class Settings {
    
    let userPasswordSecurityHash: Int?
    
    private init() {
        userPasswordSecurityHash = nil
    }
    
}


extension Settings: Codable {
    
    enum CodingKeys: String, CodingKey {
        case userPasswordSecurityHash = "user.password.security.hash"
    }
    
}


extension Settings: MockObject {
    
    static var mock: Settings {
        Settings()
    }
    
}
