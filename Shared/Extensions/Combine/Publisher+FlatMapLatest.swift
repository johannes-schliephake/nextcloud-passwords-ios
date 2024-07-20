import Combine


extension Publisher {
    
    @_disfavoredOverload func flatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P) -> some Publisher<P.Output, P.Failure> where Failure == Never {
        setFailureType(to: P.Failure.self)
            .flatMapLatest(transform)
    }
    
    @_disfavoredOverload func flatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P) -> some Publisher<P.Output, Failure> where P.Failure == Never {
        flatMapLatest {
            transform($0)
                .setFailureType(to: Failure.self)
        }
    }
    
    func flatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P) -> some Publisher<P.Output, P.Failure> where Failure == P.Failure {
        map { transform($0) }
            .switchToLatest()
    }
    
}
