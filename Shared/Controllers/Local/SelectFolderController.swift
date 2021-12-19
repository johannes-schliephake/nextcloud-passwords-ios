import Combine


final class SelectFolderController: ObservableObject {
    
    let temporaryEntry: TemporaryEntry
    let folders: [Folder]
    let selectFolder: (Folder) -> Void
    
    @Published var selection: Folder
    let baseFolder: Folder
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(entry: Entry, temporaryEntry: TemporaryEntry, folders: [Folder], selectFolder: @escaping (Folder) -> Void) {
        self.temporaryEntry = temporaryEntry
        var folders = folders
        if case .folder(let folder) = entry {
            folders = folders.filter { $0 !== folder }
        }
        folders.sort { $0.label.compare($1.label, options: [.caseInsensitive, .diacriticInsensitive, .numeric]) == .orderedAscending }
        self.folders = folders
        self.selectFolder = selectFolder
        
        let baseFolder = Folder()
        selection = folders.first(where: { $0.id == temporaryEntry.parent }) ?? baseFolder
        self.baseFolder = baseFolder
        
        folders.forEach {
            folder in
            folder.objectWillChange
                .sink { [weak self] in self?.objectWillChange.send() }
                .store(in: &subscriptions)
        }
    }
    
}


extension SelectFolderController {
    
    enum TemporaryEntry {
        
        case folder(label: String, parent: String?)
        case password(label: String, username: String, url: String, folder: String)
        
        var parent: String {
            switch self {
            case .folder(_, let parent):
                return parent ?? Entry.baseId
            case .password(_, _, _, let folder):
                return folder
            }
        }
        
    }
    
}
