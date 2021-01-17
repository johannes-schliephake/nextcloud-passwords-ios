enum Entry {
    
    case folder(Folder)
    case password(Password)
    
    static let baseId = "00000000-0000-0000-0000-000000000000"
    
    func matches(searchTerm: String) -> Bool {
        switch self {
        case .folder(let folder):
            return folder.matches(searchTerm: searchTerm)
        case .password(let password):
            return password.matches(searchTerm: searchTerm)
        }
    }
    
}


extension Entry: Identifiable {
    
    var id: String {
        switch self {
        case .folder(let folder):
            return folder.id
        case .password(let password):
            return password.id
        }
    }
    
}


extension Entry {
    
    enum EntryError: Error {
        case createError
        case editError
        case deleteError
    }
    
}
