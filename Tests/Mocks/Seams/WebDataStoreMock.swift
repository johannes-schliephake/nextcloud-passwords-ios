@testable import Passwords


final class WebDataStoreMock: WebDataStore, Mock, PropertyAccessLogging {
    
    var _httpCookieStore = HTTPCookieStoreMock() // swiftlint:disable:this identifier_name
    var httpCookieStore: HTTPCookieStoreMock {
        logPropertyAccess()
        return _httpCookieStore
    }
    
}


extension WebDataStoreMock: Equatable {
    
    static func == (lhs: WebDataStoreMock, rhs: WebDataStoreMock) -> Bool {
        lhs === rhs
    }
    
}
