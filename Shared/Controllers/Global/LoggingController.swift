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


protocol Logging {
    
    var events: [LogEvent]? { get }
    
    func log(error: Error, fileID: String, functionName: String, line: UInt)
    func log(error: String, fileID: String, functionName: String, line: UInt)
    func log(info: String, fileID: String, functionName: String, line: UInt)
    func reset()
    
}


extension Logging {
    
    func log(error: Error, fileID: String = #fileID, functionName: String = #function, line: UInt = #line) {
        log(error: error, fileID: fileID, functionName: functionName, line: line)
    }
    
    func log(error: String, fileID: String = #fileID, functionName: String = #function, line: UInt = #line) {
        log(error: error, fileID: fileID, functionName: functionName, line: line)
    }
    
    func log(info: String, fileID: String = #fileID, functionName: String = #function, line: UInt = #line) {
        log(info: info, fileID: fileID, functionName: functionName, line: line)
    }
    
}


final class LoggingController: ObservableObject, Logging {
    
    static let shared = LoggingController()
    
    @Published private(set) var events = Bundle.root.isTestFlight || Configuration.isDebug ? [LogEvent]() : nil
    
    init() {
        log(info: "Logging enabled")
    }
    
    func log(error: Error, fileID: String, functionName: String, line: UInt) {
        log(event: .init(type: .error, message: .init(describing: error), fileID: fileID, functionName: functionName, line: line))
    }
    
    func log(error: String, fileID: String, functionName: String, line: UInt) {
        log(event: .init(type: .error, message: error, fileID: fileID, functionName: functionName, line: line))
    }
    
    func log(info: String, fileID: String, functionName: String, line: UInt) {
        log(event: .init(type: .info, message: info, fileID: fileID, functionName: functionName, line: line))
    }
    
    func reset() {
        events?.removeAll()
        log(info: "Log cleared")
    }
    
    private func log(event: LogEvent) {
        DispatchQueue.main.async {
            [self] in
            events?.append(event)
        }
#if DEBUG
        print(event) // swiftlint:disable:this print
#endif
    }
    
}
