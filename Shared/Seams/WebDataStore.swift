import WebKit


protocol WebDataStore {
    
    associatedtype HTTPCookieStoreType: HTTPCookieStore
    
    var httpCookieStore: HTTPCookieStoreType { get }
    
}


extension WKWebsiteDataStore: WebDataStore {}
