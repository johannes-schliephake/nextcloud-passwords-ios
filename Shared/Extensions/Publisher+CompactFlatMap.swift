import Combine


extension Publisher {
    
    func compactFlatMap<P: Publisher>(_ transform: @escaping (Self.Output) -> P?) -> some Publisher<P.Output, P.Failure> where Self.Failure == Never {
        compactMap { transform($0) }
            .switchToLatest()
    }
    
}
