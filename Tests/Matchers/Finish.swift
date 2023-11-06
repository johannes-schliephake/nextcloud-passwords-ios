import Nimble
import XCTest
import Combine


func finish<P: Publisher>(
    within timeout: TimeInterval = 0.1,
    onMainThread expectMainThread: Bool? = nil,
    when block: (() -> Void)? = nil,
    from originQueue: DispatchQueue = .main
) -> Matcher<P> {
    .init { expression in
        var message = ExpectationMessage.expectedTo("finish")
        
        guard let publisher = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        
        let expectation = XCTestExpectation()
        var result: MatcherResult?
        var cancellables = Set<AnyCancellable>()
        publisher
            .sink { completion in
                switch completion {
                case .finished:
                    var matches = true
                    if let expectMainThread {
                        matches = matches && Thread.isMainThread == expectMainThread
                        message = message.appended(message: " on \(Thread.isMainThread ? "main" : "background") thread")
                    }
                    result = result ?? .init(status: .init(bool: matches), message: message)
                case let .failure(error):
                    result = result ?? .init(status: .doesNotMatch, message: message.appended(message: " - completed with failure <\(error)>"))
                }
                expectation.fulfill()
            } receiveValue: { value in
                result = result ?? .init(status: .doesNotMatch, message: message.appended(message: " - received value <\(stringify(value))>"))
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        originQueue.async(flags: .enforceQoS) {
            block?()
        }
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: " - didn't complete"))
    }
}
