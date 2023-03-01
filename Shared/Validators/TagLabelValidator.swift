protocol TagLabelValidating: Validating where Entity == String {}


struct TagLabelValidator: TagLabelValidating {
    
    func validate(_ entity: String) -> Bool {
        1...48 ~= entity.count
    }
    
}
