import Foundation


protocol FileManaging {
    
    func containerURL(forSecurityApplicationGroupIdentifier: String) -> URL?
    func fileExists(atPath: String) -> Bool
    func copyItem(at: URL, to: URL) throws // swiftlint:disable:this identifier_name
    
}


extension FileManager: FileManaging {}
