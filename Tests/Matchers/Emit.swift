import Nimble
import XCTest
import Combine


func emit<P: Publisher>(
    within timeout: TimeInterval = 0.1,
    onMainThread expectMainThread: Bool? = nil,
    when block: (() -> Void)? = nil,
    from originQueue: DispatchQueue = .main
) -> Matcher<P> {
    .init { expression in
        var message = ExpectationMessage.expectedTo("emit")
        
        guard let publisher = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        
        let expectation = XCTestExpectation()
        var result: MatcherResult?
        var cancellables = Set<AnyCancellable>()
        publisher
            .sink { _ in
                var matches = true
                message = message.appended(message: " - received value")
                if let expectMainThread {
                    matches = matches && Thread.isMainThread == expectMainThread
                    message = message.appended(message: " on \(Thread.isMainThread ? "main" : "background") thread")
                }
                result = result ?? .init(status: .init(bool: matches), message: message)
                expectation.fulfill()
            } receiveError: { error in
                result = result ?? .init(status: .doesNotMatch, message: message.appended(message: " - completed with failure <\(error)>"))
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        originQueue.async(flags: .enforceQoS) {
            block?()
        }
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: " - didn't receive value"))
    }
}


func emit<P: Publisher>(
    _ expectedValue: P.Output,
    within timeout: TimeInterval = 0.1,
    onMainThread expectMainThread: Bool? = nil,
    when block: (() -> Void)? = nil,
    from originQueue: DispatchQueue = .main
) -> Matcher<P> where P.Output: Equatable {
    .init { expression in
        var message = ExpectationMessage.expectedTo("emit <\(stringify(expectedValue))>")
        
        guard let publisher = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        
        let expectation = XCTestExpectation()
        var result: MatcherResult?
        var cancellables = Set<AnyCancellable>()
        publisher
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                result = result ?? .init(status: .doesNotMatch, message: message.appended(message: " - completed with failure <\(error)>"))
                expectation.fulfill()
            } receiveValue: { value in
                var matches = value == expectedValue
                message = message.appended(message: " - received value <\(stringify(value))>")
                if let expectMainThread {
                    matches = matches && Thread.isMainThread == expectMainThread
                    message = message.appended(message: " on \(Thread.isMainThread ? "main" : "background") thread")
                }
                result = result ?? .init(status: .init(bool: matches), message: message)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        originQueue.async(flags: .enforceQoS) {
            block?()
        }
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: " - didn't receive value"))
    }
}


func emit<P: Publisher>(
    _ firstExpectedValue: P.Output,
    _ otherExpectedValues: P.Output...,
    within timeout: TimeInterval = 0.1,
    onMainThread expectMainThread: Bool? = nil,
    when block: (() -> Void)? = nil,
    from originQueue: DispatchQueue = .main
) -> Matcher<P> where P.Output: Equatable {
    .init { expression in
        let expectedValues = [firstExpectedValue] + otherExpectedValues
        let result = try emit(expectedValues, within: timeout, onMainThread: expectMainThread, when: block, from: originQueue).satisfies(
            .init(expression: {
                try expression.evaluate()?.collect(expectedValues.count)
            }, location: expression.location, isClosure: expression.isClosure)
        )
        return .init(status: result.status, message: result.message)
    }
}
