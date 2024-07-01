import Nimble
import XCTest


func timeout(within timeout: NimbleTimeInterval = PollingDefaults.timeout) -> AsyncMatcher<Any> {
    .init { @MainActor expression in
        let message = ExpectationMessage.expectedTo("timeout")
        
        let expectation = XCTestExpectation()
        var result: MatcherResult?
        
        Task {
            _ = try? await expression.evaluate()
            result = .init(status: .doesNotMatch, message: message.appended(message: " - did finish"))
            expectation.fulfill()
        }
        await XCTWaiter().fulfillment(of: [expectation], timeout: timeout.timeInterval)
        return result ?? .init(status: .matches, message: message)
    }
}
