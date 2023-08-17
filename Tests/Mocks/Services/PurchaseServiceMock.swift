@testable import Passwords
import Combine


final class PurchaseServiceMock: PurchaseServiceProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let _products = PassthroughSubject<[any Product], Never>() // swiftlint:disable:this identifier_name
    var products: AnyPublisher<[any Product], Never> {
        logPropertyAccess()
        return _products.eraseToAnyPublisher()
    }
    
    let _transactionState = PassthroughSubject<TransactionState?, Never>() // swiftlint:disable:this identifier_name
    var transactionState: AnyPublisher<TransactionState?, Never> {
        logPropertyAccess()
        return _transactionState.eraseToAnyPublisher()
    }
    
    func purchase(product: any Product) {
        logFunctionCall(parameters: product)
    }
    
    func reset() {
        logFunctionCall()
    }
    
}
