import Combine


extension Publisher {
    
    func handleEvents(
        receiveSubscription: ((any Subscription) -> Void)? = nil,
        receiveOutput: ((Output) -> Void)? = nil,
        receiveFailure: ((Failure) -> Void)? = nil,
        receiveFinished: (() -> Void)? = nil,
        receiveCancel: (() -> Void)? = nil,
        receiveRequest: ((Subscribers.Demand) -> Void)? = nil
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveSubscription: receiveSubscription,
            receiveOutput: receiveOutput,
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    receiveFinished?()
                case let .failure(error):
                    receiveFailure?(error)
                }
            },
            receiveCancel: receiveCancel,
            receiveRequest: receiveRequest
        )
    }
    
}
