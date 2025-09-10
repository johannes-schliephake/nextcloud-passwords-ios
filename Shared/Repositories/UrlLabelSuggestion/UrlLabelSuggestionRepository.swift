import Combine
import Foundation
import Factory


@available(iOS 26, *) protocol UrlLabelSuggestionRepositoryProtocol: Repository where State == UrlLabelSuggestionRepository.State, Action == UrlLabelSuggestionRepository.Action {}


// TODO: tests
@available(iOS 26, *) final class UrlLabelSuggestionRepository: UrlLabelSuggestionRepositoryProtocol {
    
    final class State {
        
        @Current<String, any Error> fileprivate(set) var suggestedLabel
        
    }
    
    enum Action {
        case setUrl(URL)
    }
    
    @Injected(\.urlLabelSuggestionLanguangeModelDataSource) private var urlLabelSuggestionLanguangeModelDataSource // swiftlint:disable:this identifier_name
    
    let state: State
    
    private let urlSubject = PassthroughSubject<URL, Never>()
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setUrl(url):
            cancellable = Just(url)
                .handle(with: urlLabelSuggestionLanguangeModelDataSource, { .setUrl($0) }, publishing: \.$suggestedLabel)
                .resultize()
                .sink { [weak self] in self?.state.suggestedLabel = $0 }
        }
    }
    
}
