import Combine


extension Publisher {
    
    func optionalize() -> some Publisher<Output?, Failure> {
        map(Optional.init)
    }
    
}
