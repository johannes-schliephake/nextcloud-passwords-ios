@testable import Passwords


extension Stateful where Self: PropertyAccessLogging {
    
    subscript<Value>(_ keyPath: KeyPath<State, Value>) -> Value {
        logPropertyAccess(of: keyPath)
        return state[keyPath: keyPath]
    }
    
    subscript<Value>(_ keyPath: ReferenceWritableKeyPath<State, Value>) -> Value {
        get {
            logPropertyAccess(of: keyPath)
            return state[keyPath: keyPath]
        }
        set {
            logPropertyAccess(of: keyPath)
            return state[keyPath: keyPath] = newValue
        }
    }
    
    private func logPropertyAccess<Value>(of keyPath: KeyPath<State, Value>) {
        guard let label = String(describing: keyPath).split(separator: ".").last else {
            fatalError("Failed to log property access") // swiftlint:disable:this fatal_error
        }
        logPropertyAccess(of: String(label))
    }
    
}
