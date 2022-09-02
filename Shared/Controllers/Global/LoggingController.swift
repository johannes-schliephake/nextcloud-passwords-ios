import Foundation


final class LoggingController: ObservableObject {
    
    static let shared = LoggingController()
    
    @Published private(set) var events = Bundle.root.isTestFlight || Configuration.isDebug ? [Event]() : nil
    
    private init() {
        log(info: "Logging enabled")
    }
    
    func log(error: Error) {
        DispatchQueue.main.async {
            [self] in
            events?.append(Event(type: .error, message: error.localizedDescription))
        }
    }
    
    func log(error: String) {
        DispatchQueue.main.async {
            [self] in
            events?.append(Event(type: .error, message: error))
        }
    }
    
    func log(info: String) {
        DispatchQueue.main.async {
            [self] in
            events?.append(Event(type: .info, message: info))
        }
    }
    
    func reset() {
        events?.removeAll()
        log(info: "Log cleared")
    }
    
}


extension LoggingController {
    
    struct Event: Identifiable, CustomStringConvertible {
        
        enum `Type` { // swiftlint:disable:this nesting
            case error
            case info
        }
        
        let id = UUID()
        let type: Type
        let date = Date()
        let message: String
        
        var description: String {
            "[\(date.formattedString)] \(message.replacingOccurrences(of: "\n", with: "\n    "))"
        }
        
    }
    
}
