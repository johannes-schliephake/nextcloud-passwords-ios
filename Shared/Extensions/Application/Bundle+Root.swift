import SwiftUI


extension Bundle {
    
    static var root: Bundle {
        if UIApplication.isExtension,
           let rootBundle = Bundle(url: Self.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()) {
            return rootBundle
        }
        else {
            return Self.main
        }
    }
    
}
