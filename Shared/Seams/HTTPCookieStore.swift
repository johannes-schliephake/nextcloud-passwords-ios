import WebKit


protocol HTTPCookieStore {
    
    func getAllCookies(_ completionHandler: @escaping @MainActor ([HTTPCookie]) -> Void)
    
}


extension WKHTTPCookieStore: HTTPCookieStore {}
