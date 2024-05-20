import Combine


extension Publisher {
    
    @_disfavoredOverload func compactFlatMap<P: Publisher>(_ transform: @escaping (Self.Output) -> P?) -> some Publisher<P.Output, P.Failure> where Self.Failure == Never {
        setFailureType(to: P.Failure.self)
            .compactFlatMap(transform)
    }
    
    func compactFlatMap<P: Publisher>(_ transform: @escaping (Self.Output) -> P?) -> some Publisher<P.Output, P.Failure> where Self.Failure == P.Failure {
        compactMap { transform($0) }
            .flatMap { $0 }
    }
    
}
