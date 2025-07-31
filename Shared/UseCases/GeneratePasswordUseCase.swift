import Factory
import Combine


protocol GeneratePasswordUseCaseProtocol: UseCase where State == GeneratePasswordUseCase.State, Action == GeneratePasswordUseCase.Action {}


// TODO: tests
final class GeneratePasswordUseCase: GeneratePasswordUseCaseProtocol {
    
    final class State {
        
        @Current<String, any Error> fileprivate(set) var generatedPassword
        
    }
    
    enum Action {
        case generatePassword(includingNumbers: Bool, includingSpecialCharacters: Bool, length: Int)
    }
    
    private static let digitCharacters = Set("0123456789")
    private static let digitCharacterReplacements: [Character: Set<Character>] = ["A": "4", "a": "4", "B": "8", "b": "6", "E": "3", "e": "3", "G": "6", "g": "9", "I": "1", "i": "1", "l": "1", "O": "0", "o": "0", "S": "5", "s": "5", "T": "7", "t": "7", "Z": "2", "z": "2"].mapValues(Set.init)
    private static let specialCharacters = Set("!$%&/()+?@,.:;_#*<>=")
    private static let specialCharacterReplacements: [Character: Set<Character>] = ["A": "@", "a": "@", "C": "(", "c": "(", "H": "#", "h": "#", "I": "!/", "i": "!/", "l": "!/", "S": "$", "s": "$", "T": "+", "t": "+", "X": "%", "x": "%"].mapValues(Set.init)
    
    @LazyInjected(\.randomWordUseCase) private var randomWordUseCase
    @LazyInjected(\.wordlistLocaleUseCase) private var wordlistLocaleUseCase
    
    let state: State
    
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .generatePassword(includingNumbers, includingSpecialCharacters, length):
            weak var `self` = self
            
            @Injected(\.randomNumberGenerator) var randomNumberGenerator
            let wordlistLocale = self?.wordlistLocaleUseCase[\.wordlistLocale]?.get()
            
            /// Wordlists only contain words with at least 3 characters, plus 1 for dashes if special characters are included
            let minimumChunkLength = 3 + (includingSpecialCharacters ? 1 : 0)
            
            /// Combine character sets as requested
            let characterReplacementPool: [Character: Set<Character>]
            let characterPool: Set<Character>
            switch (includingNumbers, includingSpecialCharacters) {
            case (true, true):
                characterReplacementPool = Self.digitCharacterReplacements.merging(Self.specialCharacterReplacements) { $0.union($1) }
                characterPool = Self.digitCharacters.union(Self.specialCharacters)
            case (true, false):
                characterReplacementPool = Self.digitCharacterReplacements
                characterPool = Self.digitCharacters
            case (false, true):
                characterReplacementPool = Self.specialCharacterReplacements
                characterPool = Self.specialCharacters
            case (false, false):
                characterReplacementPool = [:]
                characterPool = []
            }
            
            /// Build an additional group of random characters to insert into the password
            let randomCharactersInsertionGroup = includingSpecialCharacters ? {
                let lengthRange = (length / 24 + 1)...((length + 2) / 8)
                let length = Int.random(in: lengthRange, using: &randomNumberGenerator)
                let randomCharacters = (0..<length).compactMap { _ in characterPool.randomElement(using: &randomNumberGenerator) }
                return String(randomCharacters)
            }() : nil
            
            /// Receive random words and build a password from them
            var rejectedRounds = 0
            cancellable = randomWordUseCase[\.$word]
                .scan((words: [String](), expectedCount: 0)) { previousResult, word in
                    let words = previousResult.words + [word]
                    /// Calculate expected password length
                    let charactersCount = words.map(\.count).reduce(0, +)
                    let dashesCount = includingSpecialCharacters ? words.count : 0
                    let expectedCount = charactersCount + dashesCount + (randomCharactersInsertionGroup?.count ?? 0)
                    /// Only accept new addition if password will have requested length or it will be possible to find a word that fits the remaining length
                    if expectedCount == length || expectedCount + minimumChunkLength <= length {
                        return (words, expectedCount)
                    } else {
                        /// Limit the number of rounds, reset and try again when the full length is not reached after a certain number of rounds
                        rejectedRounds += 1
                        if rejectedRounds < 100 {
                            return previousResult
                        } else {
                            rejectedRounds = 0
                            return ([], 0)
                        }
                    }
                }
                .first { $0.expectedCount >= length } /// Accept password once it reaches the desired length
                .handleEvents(receiveOutput: { _ in self?.randomWordUseCase(.stopStreamingWords) }) /// Stop stream of words
                .map(\.words)
                .map { words in
                    var words = words
                    /// Insert random characters at a random position
                    if let randomCharactersInsertionGroup {
                        let insertionIndex = Int.random(in: 0...words.count, using: &randomNumberGenerator)
                        words.insert(randomCharactersInsertionGroup, at: insertionIndex)
                    }
                    return words
                }
                .map { words in
                    if includingSpecialCharacters {
                        /// Join words with dashes for readability
                        words.joined(separator: "-")
                    } else {
                        /// Capitalize words for readability and remove diacritics, then join
                        words
                            .map { $0.capitalized(with: wordlistLocale) }
                            .map { $0.folding(options: [.diacriticInsensitive, .widthInsensitive], locale: wordlistLocale) }
                            .joined()
                    }
                }
                .map { password in
                    var password = password
                    
                    /// Find indices of characters that could be substituted
                    var substitutionCandidates: [(index: String.Index, diacriticInsensitiveCharacter: Character)] = password.indices
                        .compactMap { index in
                            String(password[index])
                                .folding(options: [.diacriticInsensitive, .widthInsensitive], locale: wordlistLocale)
                                .first
                                .map { (index, $0) }
                        }
                        .filter { characterReplacementPool.keys.contains($0.diacriticInsensitiveCharacter) }
                    
                    /// Pick a random substitution candidate, pick a random replacement character and do a replacement until the desired number of substitutions is reached or no more substitutable candidates are available
                    var remainingSubstitutions = (password.count + 5) / 10
                    while remainingSubstitutions > 0,
                          !substitutionCandidates.isEmpty {
                        guard let (indexToSubstitute, diacriticInsensitiveCharacterToSubstitute) = substitutionCandidates.randomElement(using: &randomNumberGenerator), // swiftlint:disable:this identifier_name
                              let replacementCharacterPool = characterReplacementPool[diacriticInsensitiveCharacterToSubstitute],
                              let replacementCharacter = replacementCharacterPool.randomElement(using: &randomNumberGenerator) else {
                            continue
                        }
                        password.replaceSubrange(indexToSubstitute...indexToSubstitute, with: String(replacementCharacter))
                        substitutionCandidates.removeAll { $0.index == indexToSubstitute }
                        remainingSubstitutions -= 1
                    }
                    return password
                }
                .resultize()
                .sink { self?.state.generatedPassword = $0 }
            
            /// Start generating a stream of words
            randomWordUseCase(.startStreamingWords)
        }
    }
    
}
