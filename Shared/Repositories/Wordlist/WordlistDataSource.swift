import Foundation
import Factory
import Combine


protocol WordlistDataSourceProtocol: FileDataSource where State == WordlistDataSource.State, Action == WordlistDataSource.Action {}


// TODO: tests
final class WordlistDataSource: WordlistDataSourceProtocol {
    
    final class State {
        
        @Current<Data, any Error> fileprivate(set) var data
        
    }
    
    enum Action {
        case setLanguage(String)
    }
    
    @LazyInjected(\.wordlistPreparationDataSource) private var wordlistPreparationDataSource
    
    let state: State
    
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setLanguage(language):
            weak var `self` = self
            
            cancellable = Just(language)
                .handle(with: wordlistPreparationDataSource, { .setLanguage($0) }, publishing: \.$wordlistUrl)
                .tryCompactMap { try self?.readFile(from: $0) }
                .resultize()
                .sink { self?.state.data = $0 }
        }
    }
    
}
