import Foundation


struct LogEvent: Identifiable, CustomStringConvertible {
    
    enum `Type`: CustomStringConvertible {
        
        case error
        case info
        
        var description: String {
            switch self {
            case .error:
                return "⚠️"
            case .info:
                return "ℹ️"
            }
        }
        
    }
    
    let id = UUID()
    let type: Type
    let message: String
    let date = Date()
    let fileID: String
    let functionName: String
    let line: UInt
    
    var description: String {
        """
        \(type) \(message.replacingOccurrences(of: "\n", with: "\n    "))
            [file \(fileID), function \(functionName), line \(line)]
            [\(Self.dateFormatter.string(from: date))]
        """
    }
    
    private static let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss.SSS"
        return dateFormatter
    }()
    
}
