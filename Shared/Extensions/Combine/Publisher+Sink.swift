import Combine


extension Publisher {
    
    func sink(receiveValue: @escaping (Output) -> Void, receiveFailure: @escaping (Failure) -> Void) -> AnyCancellable {
        sink { completion in
            guard case let .failure(error) = completion else {
                return
            }
            receiveFailure(error)
        } receiveValue: { value in
            receiveValue(value)
        }
    }
    
}
