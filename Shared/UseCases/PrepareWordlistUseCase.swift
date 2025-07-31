import Combine
import Factory


protocol PrepareWordlistUseCaseProtocol: UseCase where State == PrepareWordlistUseCase.State, Action == PrepareWordlistUseCase.Action {}


// TODO: replace temporary implementation
final class PrepareWordlistUseCase: PrepareWordlistUseCaseProtocol {
    
    final class State {
        
        @Current<Void, any Error> fileprivate(set) var preparationSignal
        
    }
    
    enum Action {
        case prepareWordlist
    }
    
    @LazyInjected(\.wordlistLocaleUseCase) var wordlistLocaleUseCase
    @LazyInjected(\.wordlistPreparationDataSource) private var wordlistPreparationDataSource
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .prepareWordlist:
            wordlistLocaleUseCase[\.$wordlistLocale]
                .map(\.identifier)
                .handle(with: wordlistPreparationDataSource, { .setLanguage($0) }, publishing: \.$wordlistUrl)
                .ignoreValue()
                .resultize()
                .sink { [weak self] in self?.state.preparationSignal = $0 }
                .store(in: &cancellables)
        }
    }
    
}
