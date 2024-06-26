import Combine


extension Publisher {
    
    func replaceOutput<P: Publisher>(with publisher: P) -> some Publisher<P.Output, Failure> where Failure == P.Failure {
        ignoreOutput()
            .ignoreValue()
            .prepend(())
            .flatMapLatest { publisher }
    }
    
}
