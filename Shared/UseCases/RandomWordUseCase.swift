import Combine
import Foundation
import Factory


protocol RandomWordUseCaseProtocol: UseCase where State == RandomWordUseCase.State, Action == RandomWordUseCase.Action {}


enum RandomWordError: Error, CustomStringConvertible {
    
    case cannotParseWord
    
    var description: String {
        switch self {
        case .cannotParseWord:
            "Unable to parse word from wordlist"
        }
    }
    
}


// TODO: tests
final class RandomWordUseCase: RandomWordUseCaseProtocol {
    
    final class State {
        
        @Current<String, any Error> fileprivate(set) var word
        
    }
    
    enum Action {
        case startStreamingWords
        case stopStreamingWords
    }
    
    let state: State
    
    private var isRunning = false
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .startStreamingWords:
            weak var `self` = self
            
            isRunning = true
            
            @Injected(\.wordlistLocaleUseCase) var wordlistLocaleUseCase
            @Injected(\.wordlistRepository) var wordlistRepository
            @Injected(\.randomNumberGenerator) var randomNumberGenerator
            
            cancellable = wordlistLocaleUseCase[\.$wordlistLocale]
                .map(\.identifier)
                .handle(with: wordlistRepository, { .setLanguage($0) }, publishing: \.$words)
                .first()
                .sink { words in
                    while let self,
                          self.isRunning {
                        guard let wordData = words.randomElement(using: &randomNumberGenerator),
                              let word = String(data: wordData, encoding: .utf8) else { // swiftlint:disable:this non_optional_string_data_conversion
                            self.state.word = .failure(RandomWordError.cannotParseWord)
                            return
                        }
                        self.state.word = .success(word)
                    }
                } receiveFailure: { error in
                    self?.state.word = .failure(error)
                }
        case .stopStreamingWords:
            isRunning = false
        }
    }
    
}
