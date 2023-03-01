protocol FolderLabelValidating: Validating where Entity == String {}


struct FolderLabelValidator: FolderLabelValidating {
    
    func validate(_ entity: String) -> Bool {
        1...48 ~= entity.count
    }
    
}
