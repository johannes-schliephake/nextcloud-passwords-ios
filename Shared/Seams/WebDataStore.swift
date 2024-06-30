import WebKit


protocol WebDataStore: AnyObject {
    
    associatedtype HTTPCookieStoreType: HTTPCookieStore
    
    var httpCookieStore: HTTPCookieStoreType { get }
    
}


extension WKWebsiteDataStore: WebDataStore {}
