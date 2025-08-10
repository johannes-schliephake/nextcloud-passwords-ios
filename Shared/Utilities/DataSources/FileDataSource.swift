import Foundation
import Factory


enum FileError: Error, CustomStringConvertible {
    
    case cannotOpen(fileName: String)
    case cannotRead(fileName: String)
    
    var description: String {
        switch self {
        case let .cannotOpen(fileName):
            "Unable to open file \(fileName)"
        case let .cannotRead(fileName):
            "Unable to read from file \(fileName)"
        }
    }
    
}


protocol FileDataSource: DataSource {}


// TODO: tests
extension FileDataSource {
    
    func readFile(from fileUrl: URL) throws(FileError) -> Data {
        @Injected(\.fileHandleType) var fileHandleType
        
        guard let fileHandle = try? fileHandleType.init(forReadingFrom: fileUrl) else {
            throw .cannotOpen(fileName: fileUrl.lastPathComponent)
        }
        guard let fileData = try? fileHandle.readToEnd() else {
            throw .cannotRead(fileName: fileUrl.lastPathComponent)
        }
        return fileData
    }
    
}
