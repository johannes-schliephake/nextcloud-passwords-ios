enum Entry: Identifiable {
    
    case folder(Folder)
    case password(Password)
    
    static let baseId = "00000000-0000-0000-0000-000000000000"
    
    var id: String {
        switch self {
        case .folder(let folder):
            return folder.id
        case .password(let password):
            return password.id
        }
    }
    
    var label: String {
        switch self {
        case .folder(let folder):
            return folder.label
        case .password(let password):
            return password.label
        }
    }
    
    var parent: String? {
        switch self {
        case .folder(let folder):
            return folder.parent
        case .password(let password):
            return password.folder
        }
    }
    
    func score(searchTerm: String) -> Double {
        switch self {
        case .folder(let folder):
            return folder.score(searchTerm: searchTerm)
        case .password(let password):
            return password.score(searchTerm: searchTerm)
        }
    }
    
}


extension Entry {
    
    enum State {
        
        case creating
        case updating
        case deleting
        case creationFailed
        case updateFailed
        case deletionFailed
        case decryptionFailed
        
        var isProcessing: Bool {
            [.creating, .updating, .deleting].contains(self)
        }
        
        var isError: Bool {
            [.creationFailed, .updateFailed, .deletionFailed, .decryptionFailed].contains(self)
        }
        
    }
    
}
