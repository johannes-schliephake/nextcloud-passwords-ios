import Combine
import Factory
import Foundation


protocol ProductsRepositoryProtocol {
    
    var products: AnyPublisher<[any Product], Never> { get }
    
}


// TODO: tests
final class ProductsRepository: ProductsRepositoryProtocol {
    
    @Injected(\.productIdentifiersRepository) private var productIdentifiersRepository
    @Injected(\.productsAppStoreDataSource) private var productsAppStoreDataSource
    @LazyInjected(\.logger) private var logger
    
    var products: AnyPublisher<[any Product], Never> {
        $productsInternal
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    @Published private var productsInternal: [any Product]?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        productIdentifiersRepository.productIdentifiers
            .flatMapLatest(productsAppStoreDataSource.products)
            .handleEvents(receiveFailure: { error in
                self?.logger.log(error: error)
            })
            .catch { error in
                Fail(error: error)
                    .delay(for: 60, scheduler: DispatchQueue())
            }
            .retry(3)
            .ignoreFailure()
            .sink { self?.productsInternal = $0 }
            .store(in: &cancellables)
    }
    
}
