import Combine
import SwiftUI


protocol WindowSizeServiceProtocol {
    
    var windowSize: CGSize? { get }
    
}


// TODO: tests
final class WindowSizeService: WindowSizeServiceProtocol {
    
    var windowSize: CGSize?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupPipelines()
    }
    
    private func setupPipelines() {
        NotificationCenter.default.publisher(for: UIScene.didActivateNotification)
            .map(\.object)
            .compactMap { $0 as? UIWindowScene }
            .compactMap(\.keyWindow)
            .flatMap { $0.publisher(for: \.frame) }
            .map(\.size)
            .removeDuplicates()
            .sink { [weak self] in self?.windowSize = $0 }
            .store(in: &cancellables)
    }
    
}
