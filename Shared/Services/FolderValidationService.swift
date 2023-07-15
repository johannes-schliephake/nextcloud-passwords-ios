import Factory


protocol FolderValidationServiceProtocol {
    
    func validate(label: String, parent: String) -> Bool
    
}


// TODO: replace temporary implementation
struct FolderValidationService: FolderValidationServiceProtocol {
    
    @Injected(\.entriesController) private var entriesController
    
    func validate(label: String, parent: String) -> Bool {
        1...48 ~= label.count
        && (parent == Entry.baseId || entriesController.folders?.contains { $0.id == parent } == true)
    }
    
}
