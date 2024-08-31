import WebKit


protocol HTTPCookieStore: AnyObject {
    
    @MainActor func getAllCookies(_ completionHandler: @escaping @MainActor @Sendable ([HTTPCookie]) -> Void)
    
}


extension WKHTTPCookieStore: HTTPCookieStore {}
