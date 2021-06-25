import Foundation


extension URL {
    
    var relativeReference: String {
        var urlComponents = URLComponents()
        urlComponents.path = path
        urlComponents.query = query
        urlComponents.fragment = fragment
        return urlComponents.string ?? ""
    }
    
}
