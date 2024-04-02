import Foundation


struct LoginURL {
    
    let value: URL
    
    init?(string: String) {
        guard let url = URL(string: string),
              url.host != nil,
              url.scheme?.lowercased() == "https" else {
            return nil
        }
        value = url
    }
    
}
