import Foundation


struct LoginURL: Equatable {
    
    let value: URL
    
    init?(string: String) {
        guard let url = URL(string: string),
              url.host != nil,
              url.scheme?.lowercased() == "https" else {
            return nil
        }
        value = url.appendingPathComponent("index.php/login/v2")
    }
    
}
