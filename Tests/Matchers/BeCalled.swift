// swiftlint:disable:this file_name

import Nimble


enum CallCount {
    
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


func beCalled<L: FunctionCallLogging>(_ callCount: CallCount = .anyNumberOfTimes, on expectedCall: String? = nil) -> Predicate<L> {
    beCalled(callCount, on: expectedCall, withParameters: [], atCallIndex: nil)
}


func beCalled<L: FunctionCallLogging>(_ callCount: CallCount = .anyNumberOfTimes, on expectedCall: String? = nil, withParameters expectedParameters: [any Equatable], atCallIndex parameterCallIndex: Int? = nil) -> Predicate<L> {
    Predicate { expression in
        var message: ExpectationMessage
        if let expectedCall {
            message = .expectedTo("call <\(expectedCall)>")
        } else {
            message = .expectedTo("call")
        }
        if callCount.rawValue > 0 {
            message = message.appended(message: " \(callCount.rawValue) times")
        }
        
        guard let functionCallLogger = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        let calls: [FunctionCallLogging.FunctionCall]
        if let expectedCall {
            calls = functionCallLogger.functionCallLog(of: expectedCall)
        } else {
            calls = functionCallLogger.functionCallLog
        }
        
        if callCount.rawValue > 0,
           calls.count != callCount.rawValue {
            return .init(status: .doesNotMatch, message: message.appended(message: ", but got called \(calls.count) times"))
        }
        if calls.isEmpty {
            return .init(status: .doesNotMatch, message: message.appended(message: ", but didn't"))
        }
        
        guard !expectedParameters.isEmpty else {
            return .init(status: .matches, message: message)
        }
        
        let parameters: [[any Equatable]]
        if let parameterCallIndex {
            parameters = [calls[parameterCallIndex].parameters]
        } else {
            parameters = calls.map(\.parameters)
        }
        guard parameters.map(\.count).allSatisfy({ $0 == expectedParameters.count }) else {
            return .init(status: .doesNotMatch, message: message.appended(message: ", but parameter count doesn't match"))
        }
        guard parameters.allSatisfy({ compare($0, to: expectedParameters) }) else {
            return .init(status: .doesNotMatch, message: message.appended(message: ", but parameters don't match"))
        }
        return .init(status: .matches, message: message)
    }
}


private func compare(_ equatables: [any Equatable], to expected: [any Equatable]) -> Bool {
    for (equatable, expected) in zip(equatables, expected) {
        guard compare(equatable, to: expected) else {
            return false
        }
    }
    return true
}


private func compare<E: Equatable>(_ equatable: E, to expected: some Equatable) -> Bool {
    equatable == expected as? E
}
