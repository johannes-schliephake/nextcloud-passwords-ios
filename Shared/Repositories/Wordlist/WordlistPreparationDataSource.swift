import Foundation
import Factory
import Combine


protocol WordlistPreparationDataSourceProtocol: OnDemandPreparationDataSource where State == WordlistPreparationDataSource.State, Action == WordlistPreparationDataSource.Action {}


// TODO: tests
final class WordlistPreparationDataSource: WordlistPreparationDataSourceProtocol {
    
    final class State {
        
        @Current<URL, any Error> fileprivate(set) var wordlistUrl
        
    }
    
    enum Action {
        case setLanguage(String)
    }
    
    @LazyInjected(\.configurationType) var configurationType
    @LazyInjected(\.fileManager) var fileManager
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setLanguage(language):
            weak var `self` = self
            
            if case .success = state.wordlistUrl {
                return
            }
            
            let tagName = "\(language).wordlist"
            let appGroupDirectory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: configurationType.appGroup)
            guard let fileUrl = appGroupDirectory?.appendingPathComponent(tagName) else {
                state.wordlistUrl = .failure(URLError(.badURL))
                return
            }
            
            cancellable = prepareFile(tagged: tagName, target: fileUrl)
                .handleEvents(receiveOutput: { preparationResult in
                    if preparationResult == .added {
                        self?.logger.log(info: "Added wordlist for language code \(language)")
                    }
                })
                .map { _ in fileUrl }
                .resultize()
                .sink { self?.state.wordlistUrl = $0 }
        }
    }
    
}
