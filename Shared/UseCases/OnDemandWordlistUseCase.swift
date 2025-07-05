import Combine
import Factory
import Foundation


protocol OnDemandWordlistUseCaseProtocol: UseCase where Action == OnDemandWordlistUseCase.Action {}


// TODO: tests
final class OnDemandWordlistUseCase: OnDemandWordlistUseCaseProtocol {
    
    enum Action {
        case prepareWordlist
    }
    
    @LazyInjected(\.configurationType) private var configurationType
    @LazyInjected(\.wordlistLocaleUseCase) private var wordlistLocaleUseCase
    @LazyInjected(\.logger) private var logger
    
    private var cancellable: AnyCancellable?
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .prepareWordlist:
            let appGroupDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: configurationType.appGroup)
            guard let wordlistLanguage = wordlistLocaleUseCase[\.wordlistLocale]?.get().identifier,
                  let wordlistUrl = appGroupDirectory?.appendingPathComponent("\(wordlistLanguage).wordlist") else {
                logger.log(error: "Unable to build wordlist path")
                return
            }
            guard !FileManager.default.fileExists(atPath: wordlistUrl.path) else {
                return
            }
            
            weak var `self` = self
            
            let resourceRequest = NSBundleResourceRequest(tags: ["\(wordlistLanguage).wordlist"])
            cancellable = Bridge { try await resourceRequest.beginAccessingResources() }
                .map { Bundle.root.url(forResource: wordlistLanguage, withExtension: "wordlist") }
                .replaceNil(with: URLError(.resourceUnavailable))
                .tryMap { try FileManager.default.copyItem(at: $0, to: wordlistUrl) }
                .handleEvents(receiveOutput: { resourceRequest.endAccessingResources() })
                .sink {
                    self?.logger.log(info: "Added wordlist for language code \(wordlistLanguage)")
                } receiveFailure: { error in
                    self?.logger.log(error: error)
                }
        }
    }
    
}
