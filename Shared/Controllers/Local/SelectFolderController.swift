import Combine


final class SelectFolderController: ObservableObject {
    
    let entriesController: EntriesController
    let entry: Entry
    let temporaryEntry: TemporaryEntry
    let selectFolder: (Folder) -> Void
    
    @Published var selection: Folder
    let baseFolder: Folder
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(entriesController: EntriesController, entry: Entry, temporaryEntry: TemporaryEntry, selectFolder: @escaping (Folder) -> Void) {
        self.entriesController = entriesController
        self.entry = entry
        self.temporaryEntry = temporaryEntry
        self.selectFolder = selectFolder
        
        let baseFolder = Folder()
        selection = entriesController.folders?.first { $0.id == temporaryEntry.parent } ?? baseFolder
        self.baseFolder = baseFolder
        
        entriesController.objectWillChange
            .sink {
                [weak self] in
                self?.selection = self?.entriesController.folders?.first { $0 === self?.selection } ?? baseFolder /// Not only serves the purpose to reset selection if selected folder is deleted but also refreshes view when entries controller changes
            }
            .store(in: &subscriptions)
    }
    
    var folders: [Folder] {
        guard var folders = entriesController.folders else {
            return []
        }
        if case .folder(let folder) = entry {
            folders = folders.filter { $0 !== folder }
        }
        return folders.sortedByLabel()
    }
    
    var hasChanges: Bool {
        temporaryEntry.parent != selection.id
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
