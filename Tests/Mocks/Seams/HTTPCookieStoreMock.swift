@testable import Passwords
import WebKit


final class HTTPCookieStoreMock: HTTPCookieStore, Mock, FunctionCallLogging {
    
    var _getAllCookiesCompletionHandler: [HTTPCookie]? // swiftlint:disable:this identifier_name
    func getAllCookies(_ completionHandler: @escaping @MainActor ([HTTPCookie]) -> Void) {
        logFunctionCall()
        _getAllCookiesCompletionHandler.map(completionHandler)
    }
    
}
