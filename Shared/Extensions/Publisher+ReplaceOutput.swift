import Combine


extension Publisher {
    
    func replaceOutput<P: Publisher>(with publisher: P) -> some Publisher<P.Output, Failure> where Failure == P.Failure {
        ignoreOutput()
            .map { _ in }
            .prepend(())
            .flatMap { publisher }
    }
    
}
