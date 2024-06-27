import Combine


extension Publisher {
    
    @_disfavoredOverload func flatMapLatest<P: Publisher>(_ transform: @escaping (Self.Output) -> P) -> some Publisher<P.Output, P.Failure> where Self.Failure == Never {
        setFailureType(to: P.Failure.self)
            .flatMapLatest(transform)
    }
    
    func flatMapLatest<P: Publisher>(_ transform: @escaping (Self.Output) -> P) -> some Publisher<P.Output, P.Failure> where Self.Failure == P.Failure {
        map { transform($0) }
            .switchToLatest()
    }
    
}
