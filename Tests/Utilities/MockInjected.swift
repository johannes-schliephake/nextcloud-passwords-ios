@testable import Factory


@propertyWrapper struct MockInjected<T, M> {
    
    private let reference: BoxedFactoryReference
    private var mock: M! // swiftlint:disable:this implicitly_unwrapped_optional
    private var initialize = true
    
    init(_ keyPath: KeyPath<Container, Factory<T>>) {
        reference = FactoryReference<Container, T>(keypath: keyPath)
    }
    
    init<C: SharedContainer>(_ keyPath: KeyPath<C, Factory<T>>) {
        reference = FactoryReference<C, T>(keypath: keyPath)
    }
    
    var wrappedValue: M {
        mutating get {
            defer { globalRecursiveLock.unlock()  }
            globalRecursiveLock.lock()
            if initialize {
                let factory: Factory<T> = reference.factory()
                guard let mock = factory() as? M else {
                    fatalError("Failed to cast dependency to mock type") // swiftlint:disable:this fatal_error
                }
                self.mock = mock
                initialize = false
            }
            return mock
        }
    }
}
