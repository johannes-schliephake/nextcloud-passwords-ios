import Combine
import SwiftUI


final class EntriesController: ObservableObject {
    
    @Published private(set) var state: State = .loading
    @Published private(set) var folders: [Folder]? {
        /// Extend @Published behaviour to array elements
        willSet {
            foldersSubscriptions.removeAll()
        }
        didSet {
            folders?.forEach {
                folder in
                folder.objectWillChange
                    .sink { [weak self] in self?.objectWillChange.send() }
                    .store(in: &foldersSubscriptions)
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
                password.objectWillChange
                    .sink { [weak self] in self?.objectWillChange.send() }
                    .store(in: &passwordsSubscriptions)
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
            else if filterBy == .folders,
                    sortBy != .label && sortBy != .updated {
                filterBy = .all
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
        SessionController.default.$session
            .sink(receiveValue: requestEntries)
            .store(in: &subscriptions)
    }
    
    private init(folders: [Folder], passwords: [Password]) {
        self.folders = folders
        self.passwords = passwords
        state = .online
    }
    
    private func requestEntries(session: Session?) {
        guard let session = session else {
            folders = nil
            passwords = nil
            filterBy = .folders
            sortBy = .label
            reversed = false
            state = .loading
            Crypto.AES256.removeKey(named: "offlineKey")
            CoreData.default.clear(type: OfflineContainer.self)
            return
        }
        
        let listFoldersRequest = Future<[Folder], NCPasswordsRequestError> {
            promise in
            ListFoldersRequest(session: session).send {
                folders in
                guard let folders = folders else {
                    promise(.failure(.requestError))
                    return
                }
                promise(.success(folders))
            }
        }
        let listPasswordsRequest = Future<[Password], NCPasswordsRequestError> {
            promise in
            ListPasswordsRequest(session: session).send {
                passwords in
                guard let passwords = passwords else {
                    promise(.failure(.requestError))
                    return
                }
                promise(.success(passwords))
            }
        }
        Publishers.Zip(listFoldersRequest, listPasswordsRequest).sink(receiveCompletion: {
            [weak self] result in
            switch result {
            case .failure(.requestError):
                if self?.state != .offline {
                    self?.state = .error
                }
            default:
                break
            }
        }, receiveValue: {
            [weak self] folders, passwords in
            self?.merge(folders: folders, passwords: passwords)
        })
        .store(in: &subscriptions)
        
        session.append(pendingCompletion: {
            [weak self] in
            self?.fetchOfflineEntries()
        })
    }
    
    private func fetchOfflineEntries() {
        DispatchQueue.global(qos: .utility).async {
            [weak self] in
            let request = OfflineContainer.request()
            guard let offlineContainers = CoreData.default.fetch(request: request) else {
                DispatchQueue.main.async {
                    CoreData.default.clear(type: OfflineContainer.self)
                    self?.merge(folders: [], passwords: [], offline: true)
                }
                return
            }
            
            let key = Crypto.AES256.getKey(named: "offlineKey")
            let entries = try? Crypto.AES256.decrypt(offlineContainers: offlineContainers, key: key)
            
            DispatchQueue.main.async {
                guard let entries = entries else {
                    CoreData.default.clear(type: OfflineContainer.self)
                    self?.merge(folders: [], passwords: [], offline: true)
                    return
                }
                self?.merge(folders: entries.folders, passwords: entries.passwords, offline: true)
            }
        }
    }
    
    private func merge(folders: [Folder], passwords: [Password], offline: Bool = false) {
        guard SessionController.default.session != nil else {
            return
        }
        
        if !offline {
            state = .online
        }
        else if state != .online,
                !folders.isEmpty || !passwords.isEmpty {
            state = .offline
        }
        
        if self.folders == nil {
            self.folders = folders
        }
        else if let existingFolders = self.folders {
            let onlineFolders = offline ? existingFolders : folders
            let offlineFolders = offline ? folders : existingFolders
            
            let onlineFolderIDs = Set(onlineFolders.map { $0.id })
            let offlineFolderIDs = Set(offlineFolders.map { $0.id })
            
            let deletedFolderIDs = offlineFolderIDs.subtracting(onlineFolderIDs)
            let updatedFolderIDs = onlineFolderIDs.intersection(offlineFolderIDs)
            let addedFolderIDs = onlineFolderIDs.subtracting(offlineFolderIDs)
            
            let deletedFolders = offlineFolders.filter { deletedFolderIDs.contains($0.id) }
            let updatedFolderPairs = zip(offlineFolders.filter { updatedFolderIDs.contains($0.id) }, onlineFolders.filter { updatedFolderIDs.contains($0.id) })
            let addedFolders = onlineFolders.filter { addedFolderIDs.contains($0.id) }
            
            if offline {
                deletedFolders.forEach {
                    offlineFolder in
                    offlineFolder.revision = ""
                }
                updatedFolderPairs.forEach {
                    offlineFolder, onlineFolder in
                    onlineFolder.offlineContainer = offlineFolder.offlineContainer
                    onlineFolder.updateOfflineContainer()
                }
                addedFolders.forEach {
                    onlineFolder in
                    onlineFolder.updateOfflineContainer()
                }
            }
            else {
                deletedFolders.forEach {
                    offlineFolder in
                    self.folders?.removeAll { $0 === offlineFolder }
                    offlineFolder.revision = ""
                }
                updatedFolderPairs.forEach {
                    offlineFolder, onlineFolder in
                    offlineFolder.update(from: onlineFolder)
                }
                self.folders?.append(contentsOf: addedFolders)
                addedFolders.forEach {
                    onlineFolder in
                    onlineFolder.updateOfflineContainer()
                }
            }
        }
        
        if self.passwords == nil {
            self.passwords = passwords
        }
        else if let existingPasswords = self.passwords {
            let onlinePasswords = offline ? existingPasswords : passwords
            let offlinePasswords = offline ? passwords : existingPasswords
            
            let onlinePasswordIDs = Set(onlinePasswords.map { $0.id })
            let offlinePasswordIDs = Set(offlinePasswords.map { $0.id })
            
            let deletedPasswordIDs = offlinePasswordIDs.subtracting(onlinePasswordIDs)
            let updatedPasswordIDs = onlinePasswordIDs.intersection(offlinePasswordIDs)
            let addedPasswordIDs = onlinePasswordIDs.subtracting(offlinePasswordIDs)
            
            let deletedPasswords = offlinePasswords.filter { deletedPasswordIDs.contains($0.id) }
            let updatedPasswordPairs = zip(offlinePasswords.filter { updatedPasswordIDs.contains($0.id) }, onlinePasswords.filter { updatedPasswordIDs.contains($0.id) })
            let addedPasswords = onlinePasswords.filter { addedPasswordIDs.contains($0.id) }
            
            if offline {
                deletedPasswords.forEach {
                    offlinePassword in
                    offlinePassword.revision = ""
                }
                updatedPasswordPairs.forEach {
                    offlinePassword, onlinePassword in
                    onlinePassword.offlineContainer = offlinePassword.offlineContainer
                    onlinePassword.updateOfflineContainer()
                }
                addedPasswords.forEach {
                    onlinePassword in
                    onlinePassword.updateOfflineContainer()
                }
            }
            else {
                deletedPasswords.forEach {
                    offlinePassword in
                    self.passwords?.removeAll { $0 === offlinePassword }
                    offlinePassword.revision = ""
                }
                updatedPasswordPairs.forEach {
                    offlinePassword, onlinePassword in
                    offlinePassword.update(from: onlinePassword)
                }
                self.passwords?.append(contentsOf: addedPasswords)
                addedPasswords.forEach {
                    onlinePassword in
                    onlinePassword.updateOfflineContainer()
                }
            }
        }
    }
    
    func updateOfflineContainers() {
        folders?.forEach { $0.updateOfflineContainer() }
        passwords?.forEach { $0.updateOfflineContainer() }
    }
    
    func add(folder: Folder) {
        folder.state = .creating
        
        guard let session = SessionController.default.session else {
            folder.state = .creationFailed
            return
        }
        folders?.append(folder)
        
        CreateFolderRequest(session: session, folder: folder).send {
            response in
            guard let response = response else {
                folder.state = .creationFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createFolderErrorMessage".localized)
                return
            }
            folder.state = nil
            folder.id = response.id
            folder.revision = response.revision
        }
    }
    
    func add(password: Password) {
        password.state = .creating
        
        guard let session = SessionController.default.session else {
            password.state = .creationFailed
            return
        }
        passwords?.append(password)
        
        CreatePasswordRequest(session: session, password: password).send {
            response in
            guard let response = response else {
                password.state = .creationFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createPasswordErrorMessage".localized)
                return
            }
            password.state = nil
            password.id = response.id
            password.revision = response.revision
        }
    }
    
    func update(folder: Folder) {
        folder.state = .updating
        
        guard let session = SessionController.default.session else {
            folder.state = .updateFailed
            return
        }
        
        UpdateFolderRequest(session: session, folder: folder).send {
            response in
            guard let response = response else {
                folder.state = .updateFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editFolderErrorMessage".localized)
                return
            }
            folder.state = nil
            folder.revision = response.revision
        }
    }
    
    func update(password: Password) {
        password.state = .updating
        
        guard let session = SessionController.default.session else {
            password.state = .updateFailed
            return
        }
        
        UpdatePasswordRequest(session: session, password: password).send {
            response in
            guard let response = response else {
                password.state = .updateFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editPasswordErrorMessage".localized)
                return
            }
            password.state = nil
            password.revision = response.revision
        }
    }
    
    func delete(folder: Folder) {
        folder.state = .deleting
        
        guard let session = SessionController.default.session else {
            folder.state = .deletionFailed
            return
        }
        folders?.removeAll { $0 === folder }
        
        DeleteFolderRequest(session: session, folder: folder).send {
            [weak self] response in
            guard response != nil else {
                self?.folders?.append(folder)
                folder.state = .deletionFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_deleteFolderErrorMessage".localized)
                return
            }
            folder.revision = ""
        }
    }
    
    func delete(password: Password) {
        password.state = .deleting
        
        guard let session = SessionController.default.session else {
            password.state = .deletionFailed
            return
        }
        passwords?.removeAll { $0 === password }
        NotificationCenter.default.post(name: Notification.Name("deletePassword"), object: password)
        
        DeletePasswordRequest(session: session, password: password).send {
            [weak self] response in
            guard response != nil else {
                self?.passwords?.append(password)
                password.state = .deletionFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_deletePasswordErrorMessage".localized)
                return
            }
            password.revision = ""
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
                        favoriteFolders.contains { folder.isDescendentOf(folder: $0, in: folders) }
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
                        favoriteFolders.contains { password.isDescendentOf(folder: $0, in: folders) }
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
            passwords.sort { !$0.username.isEmpty && $1.username.isEmpty }
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
    
    enum State {
        case loading
        case offline
        case online
        case error
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
