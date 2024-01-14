import Combine
import AnyAsyncSequence


struct Bridge<Output, Failure: Error>: Publisher {
    
    private let priority: TaskPriority?
    private let sequence: AnyAsyncSequence<Output>
    
    init(priority: TaskPriority? = nil, operation: @escaping @Sendable () async -> Output) where Failure == Never {
        self.priority = priority
        var didRunOperation = false
        sequence = AsyncStream<Output> {
            guard !didRunOperation else {
                return nil
            }
            didRunOperation = true
            return await operation()
        }
        .eraseToAnyAsyncSequence()
    }
    
    init(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Output) where Failure == any Error {
        self.priority = priority
        var didRunOperation = false
        sequence = AsyncThrowingStream<Output, Failure> {
            guard !didRunOperation else {
                return nil
            }
            didRunOperation = true
            return try await operation()
        }
        .eraseToAnyAsyncSequence()
    }
    
    init<Sequence: AsyncSequence>(priority: TaskPriority? = nil, nonthrowing sequence: Sequence) where Sequence.Element == Output, Failure == Never {
        self.priority = priority
        self.sequence = sequence.eraseToAnyAsyncSequence()
    }
    
    init<Sequence: AsyncSequence>(priority: TaskPriority? = nil, throwing sequence: Sequence) where Sequence.Element == Output, Failure == any Error {
        self.priority = priority
        self.sequence = sequence.eraseToAnyAsyncSequence()
    }
    
    func receive<Downstream: Subscriber>(subscriber downstream: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
        let subscription = TaskSubscription(priority: priority, sequence: sequence, downstream: downstream)
        downstream.receive(subscription: subscription)
        subscription.start()
    }
    
    private class TaskSubscription<Output, Downstream: Subscriber>: Subscription where Downstream.Input == Output, Downstream.Failure == Failure {
        
        private var task: Task<(), Never>?
        private let priority: TaskPriority?
        private let sequence: AnyAsyncSequence<Output>
        private let downstream: Downstream
        
        init(priority: TaskPriority?, sequence: AnyAsyncSequence<Output>, downstream: Downstream) {
            self.priority = priority
            self.sequence = sequence
            self.downstream = downstream
        }
        
        func start() {
            task = Task(priority: priority) { [weak self] in
                guard let sequence = self?.sequence,
                      let downstream = self?.downstream else {
                    return
                }
                do {
                    for try await value in sequence {
                        try Task.checkCancellation()
                        _ = downstream.receive(value)
                    }
                    downstream.receive(completion: .finished)
                } catch {
                    guard !(error is CancellationError) else {
                        return
                    }
                    if let failableCompletion = downstream.receive(completion:) as? (Subscribers.Completion<Error>) -> Void {
                        failableCompletion(.failure(error))
                    } else {
                        downstream.receive(completion: .finished)
                    }
                }
            }
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            task?.cancel()
        }
        
    }
    
}
