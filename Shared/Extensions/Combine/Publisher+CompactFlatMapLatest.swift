import Combine


extension Publisher {
    
    @_disfavoredOverload func compactFlatMapLatest<P: Publisher>(_ transform: @escaping (Self.Output) -> P?) -> some Publisher<P.Output, P.Failure> where Self.Failure == Never {
        setFailureType(to: P.Failure.self)
            .compactFlatMapLatest(transform)
    }
    
    func compactFlatMapLatest<P: Publisher>(_ transform: @escaping (Self.Output) -> P?) -> some Publisher<P.Output, P.Failure> where Self.Failure == P.Failure {
        compactMap { transform($0) }
            .flatMapLatest { $0 }
    }
    
}
