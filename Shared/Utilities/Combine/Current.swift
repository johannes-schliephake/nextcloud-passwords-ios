import Combine


@propertyWrapper struct Current<Value, Failure: Error> {
    
    typealias Publisher = AnyPublisher<Value, Failure>
    
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
