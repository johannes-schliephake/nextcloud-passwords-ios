import Foundation
import Combine


protocol Logging {
    
    var events: [LogEvent]? { get }
    var eventsPublisher: AnyPublisher<[LogEvent]?, Never> { get }
    var isAvailable: Bool { get }
    var isAvailablePublisher: AnyPublisher<Bool, Never> { get }
    
    func log(error: Error, fileID: String, functionName: String, line: UInt)
    func log(error: String, fileID: String, functionName: String, line: UInt)
    func log(info: String, fileID: String, functionName: String, line: UInt)
    func reset()
    
}


final class Logger: Logging {
    
    @Published private(set) var events = Bundle.root.isTestFlight || Configuration.isDebug ? [LogEvent]() : nil
    var eventsPublisher: AnyPublisher<[LogEvent]?, Never> {
        $events.eraseToAnyPublisher()
    }
    
    var isAvailable: Bool {
        events?.isEmpty == false
    }
    var isAvailablePublisher: AnyPublisher<Bool, Never> {
        eventsPublisher
            .map { $0?.isEmpty == false }
            .eraseToAnyPublisher()
    }
    
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
