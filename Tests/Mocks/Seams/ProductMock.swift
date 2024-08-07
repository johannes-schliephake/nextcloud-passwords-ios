@testable import Passwords
import Foundation


final class ProductMock: Product, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    static var _products: Result<[ProductMock], any Error> = .success([]) // swiftlint:disable:this identifier_name
    static func products<Identifiers: Collection>(for identifiers: Identifiers) async throws -> [ProductMock] where Identifiers.Element == String {
        logFunctionCall(parameters: Array(identifiers))
        return try _products.get()
    }
    
    var _id = String.random() // swiftlint:disable:this identifier_name
    var id: String {
        logPropertyAccess()
        return _id
    }
    
    var _price: Decimal = 1 // swiftlint:disable:this identifier_name
    var price: Decimal {
        logPropertyAccess()
        return _price
    }
    
    var _displayName = String.random() // swiftlint:disable:this identifier_name
    var displayName: String {
        logPropertyAccess()
        return _displayName
    }
    
    var _displayPrice = String.random() // swiftlint:disable:this identifier_name
    var displayPrice: String {
        logPropertyAccess()
        return _displayPrice
    }
    
    var _purchase: Result<PurchaseResult, any Error> = .success(.unknown) // swiftlint:disable:this identifier_name
    func purchase() async throws -> PurchaseResult {
        logFunctionCall()
        return try _purchase.get()
    }
    
}


extension ProductMock: Equatable {
    
    static func == (lhs: ProductMock, rhs: ProductMock) -> Bool {
        lhs.id == rhs.id &&
        lhs.price == rhs.price &&
        lhs.displayName == rhs.displayName &&
        lhs.displayPrice == rhs.displayPrice
    }
    
}
