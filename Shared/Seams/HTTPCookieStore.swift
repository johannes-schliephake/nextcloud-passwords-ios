import WebKit


protocol HTTPCookieStore: AnyObject {
    
    func getAllCookies(_ completionHandler: @escaping @MainActor ([HTTPCookie]) -> Void)
    
}


extension WKHTTPCookieStore: HTTPCookieStore {}
