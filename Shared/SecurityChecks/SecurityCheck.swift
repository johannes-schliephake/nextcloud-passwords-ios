import Foundation


enum SecurityCheckSeverity {
    case high
    case medium
    case low
}


enum SecurityCheckError: Error {
    case checkFailed
    case fixFailed
    case fixIncomplete
}


protocol SecurityCheck {
    
    var id: UUID { get }
    var severity: SecurityCheckSeverity? { get }
    var fix: (() async throws -> Void)? { get }
    
    init() async throws
    
}
