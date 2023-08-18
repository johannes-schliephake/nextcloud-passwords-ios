import StoreKit
import AnyAsyncSequence


protocol Transaction {
    
    static var updates: AnyAsyncSequence<VerificationResult<any Transaction>> { get }
    
    var revocationReason: StoreKit.Transaction.RevocationReason? { get }
    
    func finish() async
    
}


extension StoreKit.Transaction: Transaction {}


extension Transaction where Self == StoreKit.Transaction {
    
    static var updates: AnyAsyncSequence<VerificationResult<any Transaction>> {
        updates.map(VerificationResult.init).eraseToAnyAsyncSequence()
    }
    
}
