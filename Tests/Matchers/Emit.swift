import Nimble
import XCTest
import Combine


func emit<P: Publisher>(within timeout: TimeInterval = 0.1, when block: (() -> Void)? = nil) -> Predicate<P> where P.Output == Void {
    Predicate { expression in
        let message = ExpectationMessage.expectedTo("emit")
        
        guard let publisher = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        
        let expectation = XCTestExpectation()
        var result: PredicateResult?
        var cancellables = Set<AnyCancellable>()
        publisher
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                result = .init(status: .fail, message: message.appended(message: " - completed with failure <\(error)>"))
                expectation.fulfill()
            } receiveValue: {
                result = .init(status: .matches, message: message.appended(message: " - received value"))
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        block?()
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: " - didn't receive value"))
    }
}


func emit<P: Publisher>(_ expectedValue: P.Output, within timeout: TimeInterval = 0.1, when block: (() -> Void)? = nil) -> Predicate<P> where P.Output: Equatable {
    Predicate { expression in
        let message = ExpectationMessage.expectedTo("emit <\(stringify(expectedValue))>")
        
        guard let publisher = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        
        let expectation = XCTestExpectation()
        var result: PredicateResult?
        var cancellables = Set<AnyCancellable>()
        publisher
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                result = .init(status: .fail, message: message.appended(message: " - completed with failure <\(error)>"))
                expectation.fulfill()
            } receiveValue: { value in
                result = .init(status: value == expectedValue ? .matches : .doesNotMatch, message: message.appended(message: " - received value <\(stringify(value))>"))
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        block?()
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: " - didn't receive value"))
    }
}


func fail<P: Publisher>(_ expectedError: P.Failure? = nil, within timeout: TimeInterval = 0.1, when block: (() -> Void)? = nil) -> Predicate<P> where P.Failure: Equatable {
    Predicate { expression in
        let message: ExpectationMessage
        if let expectedError {
            message = .expectedTo("fail with <\(stringify(expectedError))>")
        } else {
            message = .expectedTo("fail")
        }
        
        guard let publisher = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        
        let expectation = XCTestExpectation()
        var result: PredicateResult?
        var cancellables = Set<AnyCancellable>()
        publisher
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                let message = message.appended(message: " - completed with failure <\(error)>")
                if let expectedError,
                   error != expectedError {
                    result = .init(status: .doesNotMatch, message: message)
                } else {
                    result = .init(status: .matches, message: message)
                }
                expectation.fulfill()
            } receiveValue: { value in
                result = .init(status: .doesNotMatch, message: message.appended(message: " - received value <\(stringify(value))>"))
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        block?()
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: " - didn't complete with failure"))
    }
}
