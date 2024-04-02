import Nimble
import XCTest
import Combine


func fail<P: Publisher>(
    _ expectedError: P.Failure? = nil,
    within timeout: TimeInterval = 0.1,
    onMainThread expectMainThread: Bool? = nil,
    when block: (() -> Void)? = nil,
    from originQueue: DispatchQueue = .main
) -> Matcher<P> where P.Failure: Equatable {
    .init { expression in
        var message: ExpectationMessage
        if let expectedError {
            message = .expectedTo("fail with <\(stringify(expectedError))>")
        } else {
            message = .expectedTo("fail")
        }
        
        guard let publisher = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        
        let expectation = XCTestExpectation()
        var result: MatcherResult?
        var cancellables = Set<AnyCancellable>()
        publisher
            .sink { value in
                result = result ?? .init(status: .doesNotMatch, message: message.appended(message: " - received value <\(stringify(value))>"))
                expectation.fulfill()
            } receiveFailure: { error in
                var matches = true
                message = message.appended(message: " - completed with failure <\(error)>")
                if let expectedError {
                    matches = matches && error == expectedError
                }
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
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: " - didn't complete with failure"))
    }
}
