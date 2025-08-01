@testable import Factory


@propertyWrapper struct MockInjected<T, M> {
    
    private let thunk: () -> Factory<T>
    private var mock: M! // swiftlint:disable:this implicitly_unwrapped_optional
    private var initialize = true
    
    init(_ keyPath: KeyPath<Container, Factory<T>>) {
        self.thunk = { Container.shared[keyPath: keyPath] }
    }
    
    init<C: SharedContainer>(_ keyPath: KeyPath<C, Factory<T>>) {
        self.thunk = { C.shared[keyPath: keyPath] }
    }
    
    var wrappedValue: M {
        mutating get {
            defer { globalRecursiveLock.unlock()  }
            globalRecursiveLock.lock()
            if initialize {
                let factory = thunk()
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
