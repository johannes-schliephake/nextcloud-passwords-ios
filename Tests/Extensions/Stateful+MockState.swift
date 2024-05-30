@testable import Passwords


extension Stateful {
    
    func mockState<Value>(_ keyPath: KeyPath<State, Value>, value: Value) {
        let mirror = Mirror(reflecting: state)
        guard let label = String(describing: keyPath).split(separator: ".").last,
              let child = mirror.children.first(where: { $0.label == "_\(label)" }),
              let mockable = child.value as? any ValueMockable else {
            fatalError("Failed to retreive mockable") // swiftlint:disable:this fatal_error
        }
        mockable.mockValue(value)
    }
    
}
