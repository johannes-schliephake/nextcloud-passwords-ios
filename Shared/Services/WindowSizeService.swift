import Combine
import Factory
import Foundation


protocol WindowSizeServiceProtocol {
    
    var windowSize: CGSize? { get }
    
}


final class WindowSizeService: WindowSizeServiceProtocol {
    
    @Injected(\.windowSizeRepository) private var windowSizeRepository
    
    var windowSize: CGSize?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupPipelines()
    }
    
    private func setupPipelines() {
        windowSizeRepository.windowSize
            .sink { [weak self] in self?.windowSize = $0 }
            .store(in: &cancellables)
    }
    
}
