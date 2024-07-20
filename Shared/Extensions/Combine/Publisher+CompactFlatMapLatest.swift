import Combine


extension Publisher {
    
    @_disfavoredOverload func compactFlatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P?) -> some Publisher<P.Output, P.Failure> where Failure == Never {
        setFailureType(to: P.Failure.self)
            .compactFlatMapLatest(transform)
    }
    
    @_disfavoredOverload func compactFlatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P?) -> some Publisher<P.Output, Failure> where P.Failure == Never {
        compactFlatMapLatest {
            transform($0)?
                .setFailureType(to: Failure.self)
        }
    }
    
    func compactFlatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P?) -> some Publisher<P.Output, P.Failure> where Failure == P.Failure {
        compactMap { transform($0) }
            .flatMapLatest { $0 }
    }
    
}
