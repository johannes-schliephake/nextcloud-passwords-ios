import Combine
import Foundation
import Factory


protocol RandomWordUseCaseProtocol: UseCase where State == RandomWordUseCase.State, Action == RandomWordUseCase.Action {}


enum RandomWordError: Error, CustomStringConvertible {
    
    case cannotOpenWordlist
    case cannotReadWordlist
    case cannotVerifyWordlistIntegrity
    case cannotParseWordlist
    
    var description: String {
        switch self {
        case .cannotOpenWordlist:
            "Unable to open wordlist file"
        case .cannotReadWordlist:
            "Unable to read from wordlist file"
        case .cannotVerifyWordlistIntegrity:
            "Unable to verify wordlist integrity"
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
    
    let state: State
    
    private let words: [Data]
    private var isRunning = false
    
    init() {
        let configuration = resolve(\.configurationType)
        let appGroupDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: configuration.appGroup)
        guard let wordlistLanguage = resolve(\.wordlistLocaleUseCase)[\.wordlistLocale]?.get().identifier,
              let wordlistUrl = appGroupDirectory?.appendingPathComponent("\(wordlistLanguage).wordlist"),
              let wordlistHandle = try? FileHandle(forReadingFrom: wordlistUrl) else {
            throw RandomWordError.cannotOpenWordlist
        }
        guard let wordlist = try? wordlistHandle.readToEnd() else {
            throw RandomWordError.cannotReadWordlist
        }
        
        /// Validate wordlist integrity
        switch (wordlistLanguage, wordlist.count, Crypto.SHA256.hash(wordlist)) {
        case ("cs", 4007396, "2813323278e2cd2228cc6faedf5c76d8096ce1f9833ffdf0d0c4df4166e616cf"): break
        case ("de", 4017560, "2c9288518f41d30e54cb1da99544bb305fbc4374b40a38b23f0a02f7c649d583"): break
        case ("en", 3936682, "e6e8e231414cd119e18ccf48aca2966ba0398364bdaf12e24a69d508cadc5215"): break
        case ("fr", 3895645, "e123b9f90d45e0dc3ae018e65ccb971f35c1cb61a5749af8436523648b37b039"): break
        case ("it", 4033833, "0f9923d94ef367db411c4938c7ee1f7d3e3aa3606e01f5bbf5b5c45e0ab58192"): break
        case ("nb", 2159934, "233066dbb1b51f20542c41ef27d0227c68c617f1377b4fd080bedfd6fcff7a61"): break
        case ("pl", 4073274, "f25e0e1230280a3e65d1fdcb225bbff8cb9d8103e303d0622cd4d0d1a6225709"): break
        case ("sv", 3873783, "d0d1bccbf35becd223208e43448c513ffb0d1174033de4412e33310bff49bd44"): break
        default: throw RandomWordError.cannotVerifyWordlistIntegrity
        }
        
        self.words = wordlist.split(separator: .init(ascii: ","))
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .startStreamingWords:
            isRunning = true
            defer { isRunning = false }
            
            @Injected(\.randomNumberGenerator) var randomNumberGenerator
            
            while isRunning {
                guard let wordData = words.randomElement(using: &randomNumberGenerator),
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
