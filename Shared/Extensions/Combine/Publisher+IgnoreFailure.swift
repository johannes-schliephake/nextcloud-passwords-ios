import Combine


extension Publisher {
    
    func ignoreFailure() -> some Publisher<Output, Never> {
        self.catch { _ in Empty() }
    }
    
}
