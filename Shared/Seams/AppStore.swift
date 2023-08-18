import StoreKit


protocol AppStore {
    
    static var canMakePayments: Bool { get }
    
}


extension StoreKit.AppStore: AppStore {}
