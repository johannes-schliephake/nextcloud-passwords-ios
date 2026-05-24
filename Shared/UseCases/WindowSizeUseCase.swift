import Combine
import FactoryKit
import Foundation


protocol WindowSizeUseCaseProtocol: UseCase where State == WindowSizeUseCase.State {}


final class WindowSizeUseCase: WindowSizeUseCaseProtocol {
    
    final class State {
        
        @Current(CGSize.self) fileprivate(set) var windowSize
        
    }
    
    @Injected(\.windowRepository) private var windowRepository
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init()
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        windowRepository[\.$window]
            .flatMapLatest(\.framePublisher)
            .map(\.size)
            .removeDuplicates()
            .resultize()
            .sink { [weak self] in self?.state.windowSize = $0 }
            .store(in: &cancellables)
    }
    
}
