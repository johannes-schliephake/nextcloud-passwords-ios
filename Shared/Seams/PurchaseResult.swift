import StoreKit


enum PurchaseResult {
    
    case success(VerificationResult<any Transaction>)
    case userCancelled
    case pending
    case unknown
    
    init(_ purchaseResult: StoreKit.Product.PurchaseResult) {
        switch purchaseResult {
        case let .success(verificationResult):
            self = .success(.init(verificationResult))
        case .userCancelled:
            self = .userCancelled
        case .pending:
            self = .pending
        @unknown default:
            self = .unknown
        }
    }
    
}
