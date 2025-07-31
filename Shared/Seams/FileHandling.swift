import Foundation


protocol FileHandling {
    
    init(forReadingFrom url: URL) throws
    
    func readToEnd() throws -> Data?
    
}


extension FileHandle: FileHandling {}
