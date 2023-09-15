extension String {
    
    static let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    
    static func random(count: Int = Int.random(in: 10...60)) -> Self {
        let randomCharacters = (0..<count).map { _ in Self.characters.randomElement()! }
        return .init(randomCharacters)
    }
    
}
