import Combine
import Factory
import Foundation


protocol WordlistLocaleUseCaseProtocol: UseCase where State == WordlistLocaleUseCase.State {}


// TODO: tests
final class WordlistLocaleUseCase: WordlistLocaleUseCaseProtocol {
    
    final class State {
        
        @Current(Locale.self) fileprivate(set) var wordlistLocale
        
    }
    
    @Injected(\.onDemandResourcesPropertyListDataSource) private var onDemandResourcesPropertyListDataSource
    @LazyInjected(\.configurationType) private var configurationType
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init()
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        onDemandResourcesPropertyListDataSource.propertyListPublisher
            .handleEvents(receiveFailure: { _ in
                self?.logger.log(error: "Failed to load on-demand resource list, falling back to default wordlist language")
            })
            .map { onDemandResources in
                onDemandResources
                    .tagKeys
                    .compactMap { $0.split(separator: ".").first }
                    .map(String.init)
            }
            .replaceError(with: [])
            .map { languageIdentifiers in
                if let language = self?.configurationType.preferredLanguageIdentifier,
                   languageIdentifiers.contains(language) {
                    language
                } else {
                    "en"
                }
            }
            .map(Locale.init)
            .sink { self?.state.wordlistLocale = .success($0) }
            .store(in: &cancellables)
    }
    
}
