import Combine
import Factory


protocol ProductIdentifiersRepositoryProtocol {
    
    var productIdentifiers: AnyPublisher<[String], any Error> { get }
    
}


// TODO: tests
final class ProductIdentifiersRepository: ProductIdentifiersRepositoryProtocol {
    
    @Injected(\.productIdentifiersPropertyListDataSource) private var productIdentifiersPropertyListDataSource
    @LazyInjected(\.logger) private var logger
    
    var productIdentifiers: AnyPublisher<[String], any Error> {
        productIdentifiersPropertyListDataSource.propertyListPublisher
            .handleEvents(receiveOutput: { [weak self] productIdentifiers in
                if productIdentifiers.isEmpty {
                    self?.logger.log(info: "Received empty product identifiers list but no error")
                }
            })
            .eraseToAnyPublisher()
    }
    
}
