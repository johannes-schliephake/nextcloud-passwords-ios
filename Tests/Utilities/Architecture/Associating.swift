import ObjectiveC.runtime


private class AssociationType<Source, Value> {}


protocol Associating: AnyObject {}


extension Associating {
    
    static func getAssociated<Value: Initializable>(with source: Any = Self.self) -> Value {
        guard let value = objc_getAssociatedObject(source, associationKey(Value.self)) as? Value else {
            let value = Value()
            setAssociated(value, with: source)
            return value
        }
        return value
    }
    
    static func setAssociated<Value: Initializable>(_ value: Value, with source: Any = Self.self) {
        objc_setAssociatedObject(source, associationKey(Value.self), value, .OBJC_ASSOCIATION_RETAIN)
    }
    
    private static func associationKey<Value: Initializable>(_ valueType: Value.Type) -> UnsafeRawPointer {
        .init(
            bitPattern: UInt(
                bitPattern: .init(
                    AssociationType<Self, Value>.self
                )
            )
        )!
    }
    
    func getAssociated<Value: Initializable>(with source: Any) -> Value {
        Self.getAssociated(with: source)
    }
    
    func getAssociated<Value: Initializable>() -> Value {
        getAssociated(with: self)
    }
    
    func setAssociated<Value: Initializable>(_ value: Value, with source: Any) {
        Self.setAssociated(value, with: source)
    }
    
    func setAssociated<Value: Initializable>(_ value: Value) {
        setAssociated(value, with: self)
    }
    
}
