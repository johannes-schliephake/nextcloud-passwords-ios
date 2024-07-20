import Combine


extension Publisher {
    
    @_disfavoredOverload func sink(receiveValue: ((Output) -> Void)? = nil, receiveFailure: ((Failure) -> Void)? = nil, receiveFinished: (() -> Void)? = nil) -> AnyCancellable {
        sink { completion in
            switch completion {
            case let .failure(error):
                receiveFailure?(error)
            case .finished:
                receiveFinished?()
            }
        } receiveValue: { value in
            receiveValue?(value)
        }
    }
    
}
