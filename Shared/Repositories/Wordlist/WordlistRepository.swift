import Combine
import Foundation
import Factory


protocol WordlistRepositoryProtocol: Repository where State == WordlistRepository.State, Action == WordlistRepository.Action {}


enum WordlistError: Error, CustomStringConvertible {
    
    case cannotVerifyIntegrity
    
    var description: String {
        switch self {
        case .cannotVerifyIntegrity:
            "Unable to verify wordlist integrity"
        }
    }
    
}


// TODO: tests
final class WordlistRepository: WordlistRepositoryProtocol {
    
    final class State {
        
        @Current<[Data], any Error> fileprivate(set) var words
        
    }
    
    enum Action {
        case setLanguage(String)
    }
    
    @Injected(\.wordlistDataSource) private var wordlistDataSource
    @LazyInjected(\.cryptoSHA256Type) private var cryptoSHA256Type
    
    let state: State
    
    private let languageSubject = CurrentValueSubject<String?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init()
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        languageSubject
            .compactMap { $0 }
            .removeDuplicates()
            .handle(with: wordlistDataSource, { .setLanguage($0) }, publishing: \.$data)
            .tryMap { data -> Data in
                switch (self?.languageSubject.value, data.count, self?.cryptoSHA256Type.hash(data)) {
                case ("cs", 4007396, "2813323278e2cd2228cc6faedf5c76d8096ce1f9833ffdf0d0c4df4166e616cf"),
                     ("de", 4017560, "2c9288518f41d30e54cb1da99544bb305fbc4374b40a38b23f0a02f7c649d583"),
                     ("en", 3936682, "e6e8e231414cd119e18ccf48aca2966ba0398364bdaf12e24a69d508cadc5215"),
                     ("fr", 3895645, "e123b9f90d45e0dc3ae018e65ccb971f35c1cb61a5749af8436523648b37b039"),
                     ("it", 4033833, "0f9923d94ef367db411c4938c7ee1f7d3e3aa3606e01f5bbf5b5c45e0ab58192"),
                     ("nb", 2159934, "233066dbb1b51f20542c41ef27d0227c68c617f1377b4fd080bedfd6fcff7a61"),
                     ("pl", 4073274, "f25e0e1230280a3e65d1fdcb225bbff8cb9d8103e303d0622cd4d0d1a6225709"),
                     ("sv", 3873783, "d0d1bccbf35becd223208e43448c513ffb0d1174033de4412e33310bff49bd44"):
                    return data
                default:
                    throw WordlistError.cannotVerifyIntegrity
                }
            }
            .map { $0.split(separator: .init(ascii: ",")) }
            .resultize()
            .sink { self?.state.words = $0 }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setLanguage(language):
            languageSubject.send(language)
        }
    }
    
}
