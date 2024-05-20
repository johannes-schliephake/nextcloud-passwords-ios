import Combine
import Factory
import SwiftUI


protocol WindowSizeDataSourceProtocol {
    
    var windowSize: AnyPublisher<CGSize, Never> { get }
    
}


final class WindowSizeDataSource: WindowSizeDataSourceProtocol {
    
    @Injected(\.systemNotifications) private var systemNotifications
    
    var windowSize: AnyPublisher<CGSize, Never> {
        $windowSizeInternal
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    @Published private var windowSizeInternal: CGSize?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupPipelines()
    }
    
    private func setupPipelines() {
        systemNotifications.publisher(for: UIScene.didActivateNotification)
            .map(\.object)
            .compactMap { $0 as? any WindowScene }
            .compactMap { $0.keyWindow }
            .flatMapLatest(\.framePublisher)
            .map(\.size)
            .removeDuplicates()
            .sink { [weak self] in self?.windowSizeInternal = $0 }
            .store(in: &cancellables)
    }
    
}
