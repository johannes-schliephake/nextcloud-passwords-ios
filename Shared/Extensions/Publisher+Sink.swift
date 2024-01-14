import Combine


extension Publisher {
    
    func sink(receiveValue: @escaping (Output) -> Void, receiveError: @escaping (Failure) -> Void) -> AnyCancellable {
        sink { completion in
            guard case let .failure(error) = completion else {
                return
            }
            receiveError(error)
        } receiveValue: { value in
            receiveValue(value)
        }
    }
    
}
