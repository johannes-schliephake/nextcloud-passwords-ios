import Combine


extension Publisher {
    
    func replaceNil<T, E: Error>(with error: E) -> some Publisher<T, E> where Self.Output == T?, Self.Failure == Never {
        setFailureType(to: E.self)
            .replaceNil(with: error)
    }
    
    func replaceNil<T, E: Error>(with error: E) -> some Publisher<T, E> where Self.Output == T?, Self.Failure == E {
        tryMap { value in
            guard let value else {
                throw error
            }
            return value
        }
        .mapError { $0 as! E } // swiftlint:disable:this force_cast
    }
    
}
