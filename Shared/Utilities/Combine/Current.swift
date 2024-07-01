import Combine


@propertyWrapper struct Current<Value, Failure: Error> {
    
    private let subject: CurrentValueSubject<Result<Value, Failure>?, Never>
    
    init(wrappedValue: Value, _: Failure.Type = Never.self) {
        self.init(wrappedValue: .success(wrappedValue))
    }
    
    init(wrappedValue: Value, _: Value.Type, _: Failure.Type = Never.self) {
        self.init(wrappedValue: .success(wrappedValue))
    }
    
    init(wrappedValue: Value) {
        self.init(wrappedValue: .success(wrappedValue))
    }
    
    init(_: Value.Type, _: Failure.Type = Never.self) {
        self.init(wrappedValue: nil)
    }
    
    init() {
        self.init(wrappedValue: nil)
    }
    
    @_disfavoredOverload init(wrappedValue: Result<Value, Failure>?) {
        subject = .init(wrappedValue)
    }
    
    var wrappedValue: Result<Value, Failure>? {
        get {
            subject.value
        }
        set {
            subject.value = newValue
        }
    }
    
    var projectedValue: Publisher {
        .init(
            subject
                .compactFlatMap(\.?.publisher)
        )
    }
    
}


extension Current {
    
    struct Publisher {
        
        typealias Output = Value // swiftlint:disable:this nesting
        
        private let upstream: any Combine.Publisher<Output, Failure>
        
        init(_ upstream: any Combine.Publisher<Output, Failure>) {
            self.upstream = upstream
        }
        
    }
    
}


extension Current.Publisher: Publisher {
    
    func receive<Downstream: Subscriber>(subscriber downstream: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
        let subscription = Box(downstream)
        upstream.subscribe(subscription)
        downstream.receive(subscription: subscription)
    }
    
}


private extension Current.Publisher {
    
    final class Box<Downstream: Subscriber> where Downstream.Input == Output, Downstream.Failure == Failure {
        
        typealias Input = Output // swiftlint:disable:this nesting
        
        private var downstream: Downstream?
        private var upstream: (any Subscription)?
        
        init(_ downstream: Downstream) {
            self.downstream = downstream
        }
        
    }
    
}


extension Current.Publisher.Box: Subscriber {
    
    func receive(subscription upstream: any Subscription) {
        self.upstream = upstream
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        downstream?.receive(input) ?? .none
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        downstream?.receive(completion: completion)
    }
    
}


extension Current.Publisher.Box: Subscription {
    
    func request(_ demand: Subscribers.Demand) {
        upstream?.request(demand)
    }
    
    func cancel() {
        upstream?.cancel()
        upstream = nil
        downstream = nil
    }
    
}
