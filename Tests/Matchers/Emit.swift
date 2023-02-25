import Nimble
import XCTest
import Combine


func emit<P: Publisher>(within timeout: TimeInterval = 0.1, when block: @escaping () -> Void) -> Predicate<P> where P.Output == Void {
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
                if case let .failure(error) = completion {
                    result = .init(status: .doesNotMatch, message: message.appended(message: ", but completed with failure <\(error)>"))
                    expectation.fulfill()
                }
            } receiveValue: {
                result = .init(status: .matches, message: message)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        block()
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: ", but didn't"))
    }
}


func emit<P: Publisher>(_ expectedValue: P.Output, within timeout: TimeInterval = 0.1, when block: @escaping () -> Void) -> Predicate<P> where P.Output: Equatable {
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
                if case let .failure(error) = completion {
                    result = .init(status: .doesNotMatch, message: message.appended(message: ", but completed with failure <\(error)>"))
                    expectation.fulfill()
                }
            } receiveValue: { value in
                if value == expectedValue {
                    result = .init(status: .matches, message: message)
                } else {
                    result = .init(status: .doesNotMatch, message: message.appended(message: ", got <\(stringify(value))>"))
                }
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        block()
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: ", but didn't"))
    }
}


func notEmit<P: Publisher>(within timeout: TimeInterval = 0.1, when block: @escaping () -> Void) -> Predicate<P> {
    Predicate { expression in
        let message = ExpectationMessage.expectedTo("not emit")
        
        guard let publisher = try expression.evaluate() else {
            return .init(status: .fail, message: message.appendedBeNilHint())
        }
        
        let expectation = XCTestExpectation()
        expectation.isInverted = true
        var result: PredicateResult?
        var cancellables = Set<AnyCancellable>()
        publisher
            .sink { completion in
                if case let .failure(error) = completion {
                    result = .init(status: .doesNotMatch, message: message.appended(message: ", but completed with failure <\(error)>"))
                    expectation.fulfill()
                }
            } receiveValue: { value in
                result = .init(status: .doesNotMatch, message: message.appended(message: ", but emitted <\(stringify(value))>"))
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        block()
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .matches, message: message)
    }
}


func fail<P: Publisher>(_ expectedError: P.Failure? = nil, within timeout: TimeInterval = 0.1, when block: @escaping () -> Void) -> Predicate<P> where P.Failure: Equatable {
    Predicate { expression in
        let message = ExpectationMessage.expectedTo(expectedError != nil ? "fail with <\(stringify(expectedError!))>" : "fail")
        
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
                if let expectedError,
                   error != expectedError {
                    result = .init(status: .doesNotMatch, message: message.appended(message: ", got <\(stringify(error))>"))
                } else {
                    result = .init(status: .matches, message: message)
                }
                expectation.fulfill()
            } receiveValue: { value in
                result = .init(status: .doesNotMatch, message: message.appended(message: ", but emitted <\(stringify(value))>"))
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        block()
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result ?? .init(status: .doesNotMatch, message: message.appended(message: ", but didn't"))
    }
}
