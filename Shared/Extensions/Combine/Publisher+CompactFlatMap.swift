import Combine


extension Publisher {
    
    @_disfavoredOverload func compactFlatMap<P: Publisher>(_ transform: @escaping (Output) -> P?) -> some Publisher<P.Output, P.Failure> where Failure == Never {
        setFailureType(to: P.Failure.self)
            .compactFlatMap(transform)
    }
    
    @_disfavoredOverload func compactFlatMap<P: Publisher>(_ transform: @escaping (Output) -> P?) -> some Publisher<P.Output, Failure> where P.Failure == Never {
        compactFlatMap {
            transform($0)?
                .setFailureType(to: Failure.self)
        }
    }
    
    func compactFlatMap<P: Publisher>(_ transform: @escaping (Output) -> P?) -> some Publisher<P.Output, P.Failure> where Failure == P.Failure {
        compactMap { transform($0) }
            .flatMap { $0 }
    }
    
}
