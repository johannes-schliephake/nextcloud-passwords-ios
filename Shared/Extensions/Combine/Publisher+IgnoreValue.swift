import Combine


extension Publisher {
    
    func ignoreValue() -> some Publisher<Void, Failure> {
        map { _ in }
    }
    
}
