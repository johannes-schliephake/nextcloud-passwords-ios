import StoreKit


final class TipController: NSObject, ObservableObject {
    
    @Published private(set) var products: [SKProduct]?
    @Published var transactionState: SKPaymentTransactionState?
    
    private var productsRequest: SKProductsRequest?
    
    override init() {
        super.init()
        
        /// IAP property list is only available to main app and not the credential provider
        guard SKPaymentQueue.canMakePayments(),
              let url = Bundle.main.url(forResource: "IAP", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let productIdentifiers = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String] else {
            return
        }
        
        productsRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productsRequest?.delegate = self
        productsRequest?.start()
        SKPaymentQueue.default().add(self)
    }
    
    func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
}


extension TipController: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            [self] in
            products = response.products.sorted { $0.price.compare($1.price) == .orderedDescending }
        }
    }
    
}


extension TipController: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            transaction in
            transactionState = transaction.transactionState
            
            switch transaction.transactionState {
            case .purchasing, .deferred:
                break
            case .purchased, .restored, .failed:
                fallthrough
            @unknown default:
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
}


extension TipController: MockObject {
    
    static var mock: TipController {
        TipController()
    }
    
}
