import Combine
import FactoryKit
import SwiftUI


protocol WindowDataSourceProtocol: DataSource where State == WindowDataSource.State {}


final class WindowDataSource: WindowDataSourceProtocol {
    
    final class State {
        
        @Current((any Window).self) fileprivate(set) var window
        
    }
    
    @Injected(\.systemNotifications) private var systemNotifications
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init()
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        systemNotifications.publisher(for: UIScene.didActivateNotification)
            .map(\.object)
            .compactMap { $0 as? any WindowScene }
            .compactMap { $0.keyWindow }
            .resultize()
            .sink { [weak self] in self?.state.window = $0 }
            .store(in: &cancellables)
    }
    
}
