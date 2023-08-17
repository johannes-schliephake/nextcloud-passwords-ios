import StoreKit


protocol Product: Equatable {
    
    static func products<Identifiers: Collection>(for identifiers: Identifiers) async throws -> [Self] where Identifiers.Element == String
    
    var id: String { get }
    var price: Decimal { get }
    var displayName: String { get }
    var displayPrice: String { get }
    
    func purchase() async throws -> PurchaseResult
    
}


extension StoreKit.Product: Product {}


extension Product where Self == StoreKit.Product {
    
    func purchase() async throws -> PurchaseResult {
        .init(try await purchase())
    }
    
}
