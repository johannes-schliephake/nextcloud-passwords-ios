import Combine
import FactoryKit


protocol WindowRepositoryProtocol: Repository where State == WindowRepository.State {}


final class WindowRepository: WindowRepositoryProtocol {
    
    final class State {
        
        @Current((any Window).self) fileprivate(set) var window
        
    }
    
    @Injected(\.windowDataSource) private var windowDataSource
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init()
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        windowDataSource[\.$window]
            .resultize()
            .sink { [weak self] in self?.state.window = $0 }
            .store(in: &cancellables)
    }
    
}
