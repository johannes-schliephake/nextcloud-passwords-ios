import Foundation


protocol BundleResourceRequesting {
    
    init(tags: Set<String>, bundle: Bundle)
    
    func beginAccessingResources() async throws
    func endAccessingResources()
    
}


extension NSBundleResourceRequest: BundleResourceRequesting {}
