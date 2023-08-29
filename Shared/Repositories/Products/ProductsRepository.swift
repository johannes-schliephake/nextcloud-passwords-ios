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
            .flatMap(productsAppStoreDataSource.products)
            .handleEvents(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self?.logger.log(error: error)
                }
            })
            .catch { error in
                Fail(error: error)
                    .delay(for: 60, scheduler: DispatchQueue())
            }
            .retry(3)
            .map(Optional.init)
            .replaceError(with: nil)
            .compactMap { $0 }
            .sink { self?.productsInternal = $0 }
            .store(in: &cancellables)
    }
    
}
