import Combine
import Foundation
import Factory


protocol RandomWordUseCaseProtocol: UseCase where State == RandomWordUseCase.State, Action == RandomWordUseCase.Action {}


enum RandomWordError: Error, CustomStringConvertible {
    
    case cannotOpenWordlist
    case cannotReadWordlist
    case cannotParseWordlist
    
    var description: String {
        switch self {
        case .cannotOpenWordlist:
            "Unable to open wordlist file"
        case .cannotReadWordlist:
            "Unable to read from wordlist file"
        case .cannotParseWordlist:
            "Unable to parse word from wordlist file"
        }
    }
    
}


// TODO: tests
final class RandomWordUseCase: RandomWordUseCaseProtocol {
    
    final class State {
        
        @Current<String, RandomWordError> fileprivate(set) var word
        
    }
    
    enum Action {
        case startStreamingWords
        case stopStreamingWords
    }
    
    private static let readLength: UInt64 = (45 + 1) * 2 /// Maximum byte count of a word in wordlist, adding 1 for comma, times 2 for worst case scenario (currently English has the biggest word: cs 31, de 41, en 45, fr 25, it 18, nb 30, pl 44, sv 37)
    
    let state: State
    
    private let handle: FileHandle
    private let wordlistLength: UInt64
    private var isRunning = false
    
    init() {
        let configuration = resolve(\.configurationType)
        let appGroupDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: configuration.appGroup)
        guard let wordlistLanguage = resolve(\.wordlistLocaleUseCase)[\.wordlistLocale]?.get().identifier,
              let wordlistUrl = appGroupDirectory?.appendingPathComponent("\(wordlistLanguage).wordlist"),
              let wordlistHandle = try? FileHandle(forReadingFrom: wordlistUrl),
              let wordlistLength = try? wordlistHandle.seekToEnd() else {
            throw RandomWordError.cannotOpenWordlist
        }
        self.handle = wordlistHandle
        self.wordlistLength = wordlistLength
        
        /// Validate wordlist file integrity
        let wordlistHash = try? Crypto.SHA256.hash(wordlistHandle).base64EncodedString()
        switch (wordlistLanguage, wordlistLength, wordlistHash) {
        case ("cs", 4007396, "KBMyMnjizSIozG+u31x22Als4fmDP/3w0MTfQWbmFs8="): break
        case ("de", 4017560, "LJKIUY9B0w5Uyx2plUS7MF+8Q3S0CjiyPwoC98ZJ1YM="): break
        case ("en", 3936682, "5ujiMUFM0RnhjM9IrKKWa6A5g2S9rxLiSmnVCMrcUhU="): break
        case ("fr", 3895645, "4SO5+Q1F4Nw64BjmXMuXHzXBy2GldJr4Q2UjZIs3sDk="): break
        case ("it", 4033833, "D5kj2U7zZ9tBHEk4x+4ffT46o2BuAfW79bXEXgq1gZI="): break
        case ("nb", 2159934, "IzBm27G1HyBULEHvJ9AifGjGF/E3e0/QgL7f1vz/emE="): break
        case ("pl", 4073274, "8l4OEjAoCj5l0f3LIlu/+MudgQPjA9BiLNTQ0aYiVwk="): break
        case ("sv", 3873783, "0NG8y/Nb7NIjII5DRIxRP/sNEXQDPeRBLjMxC/9JvUQ="): break
        default: fatalError()
        }
        
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .startStreamingWords:
            isRunning = true
            defer { isRunning = false }
            
            @Injected(\.randomNumberGenerator) var randomNumberGenerator
            
            while isRunning {
                let randomOffset = UInt64.random(in: 0..<(wordlistLength - Self.readLength), using: &randomNumberGenerator)
                let chunkData: Data?
                do {
                    try handle.seek(toOffset: UInt64(randomOffset))
                    chunkData = try handle.read(upToCount: Int(Self.readLength))
                } catch {
                    state.word = .failure(.cannotReadWordlist)
                    return
                }
                let wordData = chunkData?.split(separator: .init(ascii: ","), maxSplits: 2, omittingEmptySubsequences: false)[safe: 1]
                guard let wordData,
                      let word = String(data: wordData, encoding: .utf8) else { // swiftlint:disable:this non_optional_string_data_conversion
                    state.word = .failure(.cannotParseWordlist)
                    return
                }
                state.word = .success(word)
            }
        case .stopStreamingWords:
            isRunning = false
        }
    }
    
}
