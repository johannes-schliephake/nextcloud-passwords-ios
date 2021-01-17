final class Credentials {
    
    let server: String
    let user: String
    let password: String
    
    init(server: String, user: String, password: String) {
        self.server = server
        self.user = user
        self.password = password
    }
    
}


extension Credentials: MockObject {
    
    static var mock: Credentials {
        Credentials(server: "https://example.com", user: "johannes.schliephake", password: "Qr47UtYI2Nau3ee3xP51ugl6FWbUwb7F97Yz")
    }
    
}
