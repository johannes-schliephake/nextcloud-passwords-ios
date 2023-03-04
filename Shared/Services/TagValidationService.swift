protocol TagValidationServiceProtocol {
    
    func validate(label: String) -> Bool
    
}


struct TagValidationService: TagValidationServiceProtocol {
    
    func validate(label: String) -> Bool {
        1...48 ~= label.count
    }
    
}
