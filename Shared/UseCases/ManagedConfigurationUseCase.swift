import Foundation
import Combine
import Factory


protocol ManagedConfigurationUseCaseProtocol: UseCase where State == ManagedConfigurationUseCase.State, Action == Never {}


// TODO: replace temporary implementation
final class ManagedConfigurationUseCase: ManagedConfigurationUseCaseProtocol {
    
    final class State {
        
        @Current(String?.self) fileprivate(set) var serverUrl
        
    }
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init()
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .ignoreValue()
            .prepend(())
            .map { UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed")?["serverUrl"] as? String }
            .removeDuplicates()
            .sink { self?.state.serverUrl = .success($0) }
            .store(in: &cancellables)
    }
    
}
