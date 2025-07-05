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
    
    private static let readLength: UInt64 = (62 + 1) * 2 /// Maximum byte count of a word in wordlist, adding 1 for comma, times 2 for worst case scenario (currently Ukrainian has the biggest word)
    
    let state: State
    
    private let handle: FileHandle
    private let length: UInt64
    private var isRunning = false
    
    init() {
        let configuration = resolve(\.configurationType)
        let appGroupDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: configuration.appGroup)
        guard let wordlistLanguage = resolve(\.wordlistLocaleUseCase)[\.wordlistLocale]?.get().identifier,
              let wordlistUrl = appGroupDirectory?.appendingPathComponent("\(wordlistLanguage).wordlist"),
              let handle = try? FileHandle(forReadingFrom: wordlistUrl),
              let length = try? handle.seekToEnd() else {
            throw RandomWordError.cannotOpenWordlist
        }
        guard length <= 1024 * 1024 * 4 else {
            fatalError("File is larger than expected") // swiftlint:disable:this fatal_error
        }
        self.handle = handle
        self.length = length
        
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .startStreamingWords:
            isRunning = true
            defer { isRunning = false }
            
            @Injected(\.randomNumberGenerator) var randomNumberGenerator
            
            while isRunning {
                let randomOffset = UInt64.random(in: 0..<(length - Self.readLength), using: &randomNumberGenerator)
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
