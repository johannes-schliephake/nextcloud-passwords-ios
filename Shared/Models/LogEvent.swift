import Foundation
import Factory


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
    let date = Container.shared.currentDate()
    let fileID: String
    let functionName: String
    let line: UInt
    
    var description: String {
        """
        \(type) \(message.replacingOccurrences(of: "\n", with: "\n    "))
            [\(traceDescription)]
            [\(dateDescription)]
        """
    }
    
    var trace: [String] {
        [
            "File \(fileID)",
            "Function \(functionName)",
            "Line \(line)"
        ]
    }
    
    var traceDescription: String {
        trace.joined(separator: ", ")
    }
    
    var dateDescription: String {
        Self.dateFormatter.string(from: date)
    }
    
    private static let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss.SSS"
        return dateFormatter
    }()
    
}


extension LogEvent: MockObject {
    
    static var mock: LogEvent {
        .init(type: .info, message: "I'm an event", fileID: #fileID, functionName: #function, line: #line)
    }
    
    static var mocks: [LogEvent] {
        [
            .init(type: .error, message: "I'm an error event", fileID: #fileID, functionName: #function, line: #line),
            .init(type: .info, message: "I'm an info event", fileID: #fileID, functionName: #function, line: #line)
        ]
    }
    
}


#if DEBUG

extension LogEvent: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type &&
        lhs.message == rhs.message &&
        lhs.date == rhs.date &&
        lhs.fileID == rhs.fileID &&
        lhs.functionName == rhs.functionName &&
        lhs.line == rhs.line
    }
    
}

#endif
