// swiftlint:disable:this file_name

import Nimble


enum AccessCount {
    
    case anyNumberOfTimes
    case once
    case twice
    case thrice
    case aSpecifiedAmount(Int)
    
    var rawValue: Int {
        switch self {
        case .anyNumberOfTimes:
            return 0
        case .once:
            return 1
        case .twice:
            return 2
        case .thrice:
            return 3
        case let .aSpecifiedAmount(count):
            return count
        }
    }
    
}


func beAccessed<L: PropertyAccessLogging>(_ accessCount: AccessCount = .anyNumberOfTimes, on expectedAccess: String? = nil) -> Predicate<L> {
    Predicate { expression in
        var message: ExpectationMessage
        if let expectedAccess {
            message = .expectedTo("access <\(expectedAccess)>")
        } else {
            message = .expectedTo("access")
        }
        if accessCount.rawValue > 0 {
            message = message.appended(message: " \(accessCount.rawValue) times")
        }
        
        guard let propertyAccessLogger = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        let accesses: PropertyAccessLogging.Log
        if let expectedAccess {
            accesses = propertyAccessLogger.propertyAccessLog(of: expectedAccess)
        } else {
            accesses = propertyAccessLogger.propertyAccessLog
        }
        
        if accessCount.rawValue > 0,
           accesses.count != accessCount.rawValue {
            return .init(status: .doesNotMatch, message: message.appended(message: " - got accessed \(accesses.count) times"))
        }
        if accesses.isEmpty {
            return .init(status: .doesNotMatch, message: message.appended(message: " - didn't get accessed"))
        }
        
        return .init(status: .matches, message: message)
    }
}
