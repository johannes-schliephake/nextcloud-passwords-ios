import Combine
import Factory


protocol ProductsAppStoreDataSourceProtocol {
    
    func products(for identifiers: [String]) -> AnyPublisher<[any Product], any Error>
    
}


// TODO: tests
struct ProductsAppStoreDataSource: ProductsAppStoreDataSourceProtocol {
    
    @Injected(\.productType) private var productType
    
    func products(for identifiers: [String]) -> AnyPublisher<[any Product], any Error> {
        Bridge { try await productType.products(for: identifiers) }
            .eraseToAnyPublisher()
    }
    
}
