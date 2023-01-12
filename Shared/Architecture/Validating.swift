protocol Validating {
    
    associatedtype Entity
    
    func validate(_ entity: Entity) -> Bool
    
}
