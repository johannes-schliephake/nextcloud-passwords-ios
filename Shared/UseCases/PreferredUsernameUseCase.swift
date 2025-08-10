import Combine
import Factory


protocol PreferredUsernameUseCaseProtocol: UseCase where State == PreferredUsernameUseCase.State {}


// TODO: replace temporary implementation
final class PreferredUsernameUseCase: PreferredUsernameUseCaseProtocol {
    
    final class State {
        
        @Current([String]?.self) fileprivate(set) var preferredUsernames
        
    }
    
    @Injected(\.entriesController) private var entriesController
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init()
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        entriesController.$passwords
            .map { passwords in
                passwords?
                    .filter { !$0.username.isEmpty }
                    .sorted { $0.created > $1.created }
                    .map(\.username)
                    .prefix(50)
                    .enumerated()
                    .flatMap { Array(repeating: $1, count: 12 / ($0 + 2) + 1) }
            }
            .map(\.?.countedOccurences)
            .map(\.?.keysSortedByValue)
            .removeDuplicates()
            .sink { self?.state.preferredUsernames = .success($0) }
            .store(in: &cancellables)
    }
    
}


private extension Sequence where Element: Hashable {
    
    var countedOccurences: [Element: Int] {
        reduce(into: [:]) { $0[$1, default: 0] += 1 }
    }
    
}


private extension Dictionary where Value == Int {
    
    var keysSortedByValue: [Key] {
        keys.sorted { self[$0]! > self[$1]! }
    }
    
}
