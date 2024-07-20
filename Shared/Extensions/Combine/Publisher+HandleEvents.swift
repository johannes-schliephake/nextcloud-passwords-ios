import Combine


extension Publisher {
    
    func handleEvents(
        receiveSubscription: ((any Subscription) -> Void)? = nil,
        receiveOutput: ((Output) -> Void)? = nil,
        receiveFailure: ((Failure) -> Void)? = nil,
        receiveFinished: (() -> Void)? = nil,
        receiveCancel: (() -> Void)? = nil,
        receiveRequest: ((Subscribers.Demand) -> Void)? = nil
    ) -> some Publisher<Output, Failure> {
        handleEvents(
            receiveSubscription: receiveSubscription,
            receiveOutput: receiveOutput,
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    receiveFailure?(error)
                case .finished:
                    receiveFinished?()
                }
            },
            receiveCancel: receiveCancel,
            receiveRequest: receiveRequest
        )
    }
    
}
