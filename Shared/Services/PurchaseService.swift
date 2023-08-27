import Combine
import Factory
import Foundation


enum TransactionState {
    case purchasing
    case pending
    case purchased
    case failed
}


protocol PurchaseServiceProtocol {
    
    var products: AnyPublisher<[any Product], Never> { get }
    var transactionState: AnyPublisher<TransactionState?, Never> { get }
    
    func purchase(product: any Product)
    func reset()
    
}


// TODO: tests
final class PurchaseService: PurchaseServiceProtocol {
    
    @Injected(\.productsRepository) private var productsRepository
    @Injected(\.appStoreType) private var appStoreType
    @Injected(\.transactionType) private var transactionType
    @LazyInjected(\.logger) private var logger
    
    var products: AnyPublisher<[any Product], Never> {
        $productsInternal
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    var transactionState: AnyPublisher<TransactionState?, Never> {
        $transactionStateInternal
            .eraseToAnyPublisher()
    }
    
    @Published private var productsInternal: [any Product]?
    @Published private var transactionStateInternal: TransactionState?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        /// Products are only available to main app and not the AutoFill credential provider or action extension
        guard AutoFillController.default.mode == .app else {
            return
        }
        guard appStoreType.canMakePayments else {
            logger.log(info: "This App Store account is unable to authorize payments")
            return
        }
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        productsRepository.products
            .map { $0.sorted { $0.price < $1.price } }
            .map { products in
                if #available(iOS 16, *) {
                    return products
                } else {
                    return products.reversed()
                }
            }
            .sink { self?.productsInternal = $0 }
            .store(in: &cancellables)
        
        Bridge(nonthrowing: transactionType.updates)
            .receive(on: DispatchQueue.main)
            .sink { self?.handlePurchaseResult(.success($0)) }
            .store(in: &cancellables)
    }
    
    func purchase(product: any Product) {
        weak var `self` = self
        
        transactionStateInternal = .purchasing
        
        Bridge { try await product.purchase() }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure = completion {
                    self?.transactionStateInternal = .failed
                }
            } receiveValue: { self?.handlePurchaseResult($0) }
            .store(in: &cancellables)
    }
    
    func reset() {
        guard transactionStateInternal != .purchasing else {
            logger.log(error: "ViewModel-Service inconsistency encountered, this case shouldn't be reachable")
            return
        }
        transactionStateInternal = nil
    }
    
    private func handlePurchaseResult(_ result: PurchaseResult) {
        let transactionState: TransactionState?
        switch result {
        case let .success(.unverified(transaction, error)):
            logger.log(error: error)
            fallthrough
        case let .success(.verified(transaction)):
            guard transaction.revocationReason == nil else {
                transactionState = nil
                break
            }
            transactionState = .purchased
            Bridge { await transaction.finish() }
                .sink {}
                .store(in: &cancellables)
        case .pending:
            transactionState = .pending
        case .userCancelled, .unknown:
            transactionState = nil
        }
        transactionStateInternal = transactionState
    }
    
}


#if DEBUG

extension TransactionState: CaseIterable {}

#endif
