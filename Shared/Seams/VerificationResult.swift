import StoreKit


enum VerificationResult<SignedType> {
    
    case unverified(SignedType, any Error)
    case verified(SignedType)
    
    init(_ verificationResult: StoreKit.VerificationResult<StoreKit.Transaction>) where SignedType == any Transaction {
        switch verificationResult {
        case let .verified(signedType):
            self = .verified(signedType)
        case let .unverified(signedType, error):
            self = .unverified(signedType, error)
        }
    }
    
}
