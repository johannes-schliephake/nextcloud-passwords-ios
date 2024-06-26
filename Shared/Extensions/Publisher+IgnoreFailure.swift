import Combine


extension Publisher {
    
    func ignoreFailure() -> some Publisher<Output, Never> {
        optionalize()
            .replaceError(with: nil)
            .compactMap { $0 }
    }
    
}
