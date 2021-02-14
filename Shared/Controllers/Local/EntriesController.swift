import Combine
import SwiftUI


final class EntriesController: ObservableObject {
    
    @Published private(set) var error = false
    @Published private(set) var folders: [Folder]? {
        /// Extend @Published behaviour to array elements
        willSet {
            foldersSubscriptions.removeAll()
        }
        didSet {
            folders?.forEach {
                folder in
                folder.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }.store(in: &foldersSubscriptions)
            }
        }
    }
    @Published private(set) var passwords: [Password]? {
        /// Extend @Published behaviour to array elements
        willSet {
            passwordsSubscriptions.removeAll()
        }
        didSet {
            passwords?.forEach {
                password in
                password.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }.store(in: &passwordsSubscriptions)
            }
        }
    }
    @AppStorage("filterBy", store: Configuration.userDefaults) var filterBy: Filter = .folders {
        willSet {
            /// Extend @AppStorage behaviour to be more similar to @Published
            objectWillChange.send()
        }
        didSet {
            if filterBy == .folders,
               sortBy != .label && sortBy != .updated {
                sortBy = .label
            }
        }
    }
    @AppStorage("sortBy", store: Configuration.userDefaults) var sortBy: Sorting = .label {
        willSet {
            /// Extend @AppStorage behaviour to be more similar to @Published
            objectWillChange.send()
        }
        didSet {
            if oldValue == sortBy {
                reversed.toggle()
            }
        }
    }
    @AppStorage("reversed", store: Configuration.userDefaults) var reversed = false {
        willSet {
            /// Extend @AppStorage behaviour to be more similar to @Published
            objectWillChange.send()
        }
    }
    
    private var foldersSubscriptions = Set<AnyCancellable>()
    private var passwordsSubscriptions = Set<AnyCancellable>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        CredentialsController.default.$credentials.sink(receiveValue: requestEntries).store(in: &subscriptions)
        requestEntries(credentials: CredentialsController.default.credentials)
    }
    
    private init(folders: [Folder], passwords: [Password]) {
        self.folders = folders
        self.passwords = passwords
    }
    
    private func requestEntries(credentials: Credentials?) {
        guard let credentials = credentials else {
            folders = nil
            passwords = nil
            return
        }
        
        ListFoldersRequest(credentials: credentials).send {
            [weak self] folders in
            guard let folders = folders else {
                self?.error = true
                return
            }
            self?.error = false
            self?.folders = folders
        }
        ListPasswordsRequest(credentials: credentials).send {
            [weak self] passwords in
            guard let passwords = passwords else {
                self?.error = true
                return
            }
            self?.error = false
            self?.passwords = passwords
        }
    }
    
    func add(folder: Folder) {
        guard let credentials = CredentialsController.default.credentials else {
            folder.error = .createError
            return
        }
        folders?.append(folder)
        
        CreateFolderRequest(credentials: credentials, folder: folder).send {
            response in
            guard let response = response else {
                folder.error = .createError
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createFolderErrorMessage".localized)
                return
            }
            folder.error = nil
            folder.id = response.id
            folder.revision = response.revision
        }
    }
    
    func add(password: Password) {
        guard let credentials = CredentialsController.default.credentials else {
            password.error = .createError
            return
        }
        passwords?.append(password)
        
        CreatePasswordRequest(credentials: credentials, password: password).send {
            response in
            guard let response = response else {
                password.error = .createError
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createPasswordErrorMessage".localized)
                return
            }
            password.error = nil
            password.id = response.id
            password.revision = response.revision
        }
    }
    
    func update(folder: Folder) {
        guard let credentials = CredentialsController.default.credentials else {
            folder.error = .editError
            return
        }
        
        UpdateFolderRequest(credentials: credentials, folder: folder).send {
            response in
            guard let response = response else {
                folder.error = .editError
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editFolderErrorMessage".localized)
                return
            }
            folder.error = nil
            folder.revision = response.revision
        }
        folder.revision = ""
    }
    
    func update(password: Password) {
        guard let credentials = CredentialsController.default.credentials else {
            password.error = .editError
            return
        }
        
        UpdatePasswordRequest(credentials: credentials, password: password).send {
            response in
            guard let response = response else {
                password.error = .editError
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editPasswordErrorMessage".localized)
                return
            }
            password.error = nil
            password.revision = response.revision
        }
        password.revision = ""
    }
    
    func delete(folder: Folder) {
        guard let credentials = CredentialsController.default.credentials else {
            folder.error = .deleteError
            return
        }
        folders?.removeAll { $0 === folder }
        
        DeleteFolderRequest(credentials: credentials, folder: folder).send {
            [weak self] response in
            guard response != nil else {
                self?.folders?.append(folder)
                folder.error = .deleteError
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_deleteFolderErrorMessage".localized)
                return
            }
        }
    }
    
    func delete(password: Password) {
        guard let credentials = CredentialsController.default.credentials else {
            password.error = .deleteError
            return
        }
        passwords?.removeAll { $0 === password }
        
        DeletePasswordRequest(credentials: credentials, password: password).send {
            [weak self] response in
            guard response != nil else {
                self?.passwords?.append(password)
                password.error = .deleteError
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_deletePasswordErrorMessage".localized)
                return
            }
        }
    }
    
    static func processEntries(passwords: [Password]?, folders: [Folder]?, folder: Folder, searchTerm: String, filterBy: EntriesController.Filter, sortBy: EntriesController.Sorting, reversed: Bool) -> [Entry]? {
        guard var passwords = passwords,
              var folders = folders else {
            return nil
        }
        
        /// Apply filter to folders
        switch filterBy {
        case .all:
            folders = []
        case .favorites:
            guard !folder.isBaseFolder else {
                let favoriteFolders = folders.filter { $0.favorite }
                if searchTerm.isEmpty {
                    folders = favoriteFolders
                }
                else {
                    let foldersInFavoriteFolders = folders.filter {
                        folder in
                        favoriteFolders.reduce(false) {
                            isDescendent, favoriteFolder in
                            isDescendent || folder.isDescendentOf(folder: favoriteFolder, in: folders)
                        }
                    }
                    folders = favoriteFolders + foldersInFavoriteFolders
                }
                break
            }
            fallthrough
        case .folders:
            if searchTerm.isEmpty {
                folders = folders.filter { $0.parent == folder.id }
            }
            else {
                folders = folders.filter { $0.isDescendentOf(folder: folder, in: folders) }
            }
        }
        
        /// Apply filter to passwords
        switch filterBy {
        case .all:
            break
        case .favorites:
            guard !folder.isBaseFolder else {
                let favoritePasswords = passwords.filter { $0.favorite }
                if searchTerm.isEmpty {
                    passwords = favoritePasswords
                }
                else {
                    let favoriteFolders = folders.filter { $0.favorite }
                    let passwordsInFavoriteFolders = passwords.filter {
                        password in
                        favoriteFolders.reduce(false) {
                            isDescendent, favoriteFolder in
                            isDescendent || password.isDescendentOf(folder: favoriteFolder, in: folders)
                        }
                    }
                    passwords = favoritePasswords + passwordsInFavoriteFolders
                }
                break
            }
            fallthrough
        case .folders:
            if searchTerm.isEmpty {
                passwords = passwords.filter { $0.folder == folder.id }
            }
            else {
                passwords = passwords.filter { $0.isDescendentOf(folder: folder, in: folders) }
            }
        }
        
        /// Sort folders
        switch sortBy {
        case .label:
            folders.sort { $0.label.lowercased() < $1.label.lowercased() }
        case .updated:
            folders.sort { $0.updated > $1.updated }
        default:
            folders = []
        }
        
        /// Sort passwords
        switch sortBy {
        case .label:
            passwords.sort { $0.label.lowercased() < $1.label.lowercased() }
        case .updated:
            passwords.sort { $0.updated > $1.updated }
        case .username:
            passwords.sort { $0.username.lowercased() < $1.username.lowercased() }
            passwords.sort { $0.username != "" && $1.username == "" }
        case .url:
            passwords.sort { $0.url.lowercased() < $1.url.lowercased() }
            passwords.sort { !$0.url.isEmpty && $1.url.isEmpty }
        case .status:
            passwords.sort { $0.statusCode > $1.statusCode }
        }
        
        /// Reverse order if necessary
        if reversed {
            folders.reverse()
            passwords.reverse()
        }
        
        /// Apply search term
        let unsearchedEntries: [Entry] = folders.map { .folder($0) } + passwords.map { .password($0) }
        if searchTerm.isEmpty {
            return unsearchedEntries
        }
        return unsearchedEntries.filter { $0.matches(searchTerm: searchTerm) }
    }
    
    static func processSuggestions(passwords: [Password]?, serviceURLs: [URL]?) -> [Password]? {
        guard let passwords = passwords,
              let serviceURLs = serviceURLs else {
            return nil
        }
        
        /// Search for perfectly matching URLs
        let perfectMatches = passwords.filter {
            password in
            serviceURLs.contains {
                serviceURL in
                URL(string: password.url) == serviceURL
            }
        }
        if !perfectMatches.isEmpty {
            return perfectMatches
        }
        
        /// Search for URLs with the same host
        let hostMatches = passwords.filter {
            password in
            serviceURLs.contains {
                serviceURL in
                URL(string: password.url)?.host == serviceURL.host
            }
        }
        if !hostMatches.isEmpty {
            return hostMatches
        }
        
        /// Search with search function
        let otherMatches = passwords.filter {
            password in
            serviceURLs.contains {
                serviceURL in
                guard let host = serviceURL.host else {
                    return false
                }
                return password.matches(searchTerm: host)
            }
        }
        return otherMatches
    }
    
}


extension EntriesController {
    
    enum Filter: Int {
        case folders
        case all
        case favorites
    }
    
}


extension EntriesController {
    
    enum Sorting: Int {
        case label
        case updated
        case username
        case url
        case status
    }
    
}


extension EntriesController: MockObject {
    
    static var mock: EntriesController {
        EntriesController(folders: Folder.mocks, passwords: Password.mocks)
    }
    
}
