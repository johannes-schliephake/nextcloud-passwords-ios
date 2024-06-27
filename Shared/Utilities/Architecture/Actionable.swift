protocol Actionable {
    
    associatedtype Action
    
    func callAsFunction(_ action: Action)
    
}


extension Actionable where Action == Never {
    
    func callAsFunction(_ action: Action) {}
    
}
