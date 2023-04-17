import Combine
import SwiftUI
import AuthenticationServices


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
    @Published private(set) var tags: [Tag]? {
        /// Extend @Published behaviour to array elements
        willSet {
            tagsSubscriptions.removeAll()
        }
        didSet {
            tags?.forEach {
                tag in
                tag.objectWillChange
                    .sink { [weak self] in self?.objectWillChange.send() }
                    .store(in: &tagsSubscriptions)
            }
        }
    }
    @Published var filterBy = Filter(rawValue: Configuration.userDefaults.integer(forKey: "filterBy")) ?? .folders {
        willSet {
            Configuration.userDefaults.set(newValue.rawValue, forKey: "filterBy")
            if newValue != .all,
               sortBy != .label && sortBy != .updated {
                sortBy = .label
            }
        }
    }
    @Published var sortBy = Sorting(rawValue: Configuration.userDefaults.integer(forKey: "sortBy")) ?? .label {
        willSet {
            Configuration.userDefaults.set(newValue.rawValue, forKey: "sortBy")
            if sortBy == newValue {
                reversed.toggle()
            }
            else if filterBy != .all,
                    newValue != .label && newValue != .updated {
                filterBy = .all
            }
        }
    }
    @Published var reversed = Configuration.userDefaults.object(forKey: "reversed") as? Bool ?? false {
        willSet {
            Configuration.userDefaults.set(newValue, forKey: "reversed")
        }
    }
    
    private var onlineEntriesFetchDate: Date?
    private var didMergeOfflineEntries = false
    private var listRequestsSubscription: AnyCancellable?
    private var foldersSubscriptions = Set<AnyCancellable>()
    private var passwordsSubscriptions = Set<AnyCancellable>()
    private var tagsSubscriptions = Set<AnyCancellable>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        SessionController.default.$session
            .sink(receiveValue: requestEntries)
            .store(in: &subscriptions)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink(receiveValue: refresh)
            .store(in: &subscriptions)
    }
    
    private init(folders: [Folder], passwords: [Password], tags: [Tag]) {
        self.folders = folders
        self.passwords = passwords
        self.tags = tags
        state = .online
    }
    
    private func requestEntries(session: Session?) {
        guard let session else {
            state = .loading
            folders = nil
            passwords = nil
            tags = nil
            filterBy = .folders
            sortBy = .label
            reversed = false
            onlineEntriesFetchDate = nil
            didMergeOfflineEntries = false
            listRequestsSubscription = nil
            Crypto.AES256.removeKey(named: "offlineKey")
            CoreData.default.clear(type: OfflineContainer.self)
            updateAutoFillCredentials()
            return
        }
        
        session.append(pendingCompletion: {
            [weak self] in
            self?.fetchOfflineEntries()
        })
        fetchOnlineEntries(session: session)
    }
    
    func refresh() async {
        guard let session = SessionController.default.session else {
            return
        }
        await withCheckedContinuation {
            continuation in
            fetchOnlineEntries(session: session) {
                continuation.resume()
            }
        }
    }
    
    func refresh(completion: (() -> Void)? = nil) {
        guard let session = SessionController.default.session else {
            completion?()
            return
        }
        fetchOnlineEntries(session: session, completion: completion)
    }
    
    private func refresh(_: Notification) {
        if let onlineEntriesFetchDate {
            guard onlineEntriesFetchDate.advanced(by: 5 * 60) < Date() else {
                return
            }
        }
        if state == .online {
            state = .offline
        }
        refresh()
    }
    
    private func fetchOnlineEntries(session: Session, completion: (() -> Void)? = nil) {
        onlineEntriesFetchDate = Date()
        
        if state == .error {
            state = .loading
        }
        
        let listFoldersRequest = Future<[Folder], NCPasswordsRequestError> {
            promise in
            ListFoldersRequest(session: session).send {
                folders in
                guard let folders else {
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
                guard let passwords else {
                    promise(.failure(.requestError))
                    return
                }
                promise(.success(passwords))
            }
        }
        let listTagsRequest = Future<[Tag], NCPasswordsRequestError> {
            promise in
            ListTagsRequest(session: session).send {
                tags in
                guard let tags else {
                    promise(.failure(.requestError))
                    return
                }
                promise(.success(tags))
            }
        }
        listRequestsSubscription = Publishers.Zip3(listFoldersRequest, listPasswordsRequest, listTagsRequest)
            .sink(receiveCompletion: {
                [weak self] result in
                if case .failure(.requestError) = result {
                    if self?.state == .loading {
                        self?.state = .error
                    }
                    else {
                        self?.state = .offline
                    }
                    self?.onlineEntriesFetchDate = nil
                }
                completion?()
            }, receiveValue: {
                [weak self] folders, passwords, tags in
                self?.merge(folders: folders, passwords: passwords, tags: tags)
                self?.updateAutoFillCredentials()
                self?.completeCredentialIdentifierAutoFill()
            })
    }
    
    private func fetchOfflineEntries() {
        DispatchQueue.global(qos: .utility).async {
            [weak self] in
            let request = OfflineContainer.request()
            guard let offlineContainers = CoreData.default.fetch(request: request) else {
                DispatchQueue.main.async {
                    CoreData.default.clear(type: OfflineContainer.self)
                    self?.merge(folders: [], passwords: [], tags: [], offline: true)
                }
                return
            }
            
            let key = Crypto.AES256.getKey(named: "offlineKey")
            do {
                let entries = try Crypto.AES256.decrypt(offlineContainers: offlineContainers, key: key)
                DispatchQueue.main.async {
                    self?.merge(folders: entries.folders, passwords: entries.passwords, tags: entries.tags, offline: true)
                    self?.completeCredentialIdentifierAutoFill()
                }
            }
            catch {
                DispatchQueue.main.async {
                    CoreData.default.clear(type: OfflineContainer.self)
                    self?.merge(folders: [], passwords: [], tags: [], offline: true)
                }
                Logger.shared.log(error: error)
            }
        }
    }
    
    private func merge(folders: [Folder], passwords: [Password], tags: [Tag], offline: Bool = false) {
        guard SessionController.default.session != nil else {
            return
        }
        
        if !offline {
            state = .online
        }
        else if state != .online,
                !folders.isEmpty || !passwords.isEmpty || !tags.isEmpty {
            state = .offline
        }
        
        if offline {
            didMergeOfflineEntries = true
        }
        
        if self.folders == nil || !offline && !didMergeOfflineEntries {
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
            let updatedFolderPairs = zip(offlineFolders.filter { updatedFolderIDs.contains($0.id) }.sorted { $0.id < $1.id }, onlineFolders.filter { updatedFolderIDs.contains($0.id) }.sorted { $0.id < $1.id })
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
        
        if self.passwords == nil || !offline && !didMergeOfflineEntries {
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
            let updatedPasswordPairs = zip(offlinePasswords.filter { updatedPasswordIDs.contains($0.id) }.sorted { $0.id < $1.id }, onlinePasswords.filter { updatedPasswordIDs.contains($0.id) }.sorted { $0.id < $1.id })
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
        
        if self.tags == nil || !offline && !didMergeOfflineEntries {
            self.tags = tags
        }
        else if let existingTags = self.tags {
            let onlineTags = offline ? existingTags : tags
            let offlineTags = offline ? tags : existingTags
            
            let onlineTagIDs = Set(onlineTags.map { $0.id })
            let offlineTagIDs = Set(offlineTags.map { $0.id })
            
            let deletedTagIDs = offlineTagIDs.subtracting(onlineTagIDs)
            let updatedTagIDs = onlineTagIDs.intersection(offlineTagIDs)
            let addedTagIDs = onlineTagIDs.subtracting(offlineTagIDs)
            
            let deletedTags = offlineTags.filter { deletedTagIDs.contains($0.id) }
            let updatedTagPairs = zip(offlineTags.filter { updatedTagIDs.contains($0.id) }.sorted { $0.id < $1.id }, onlineTags.filter { updatedTagIDs.contains($0.id) }.sorted { $0.id < $1.id })
            let addedTags = onlineTags.filter { addedTagIDs.contains($0.id) }
            
            if offline {
                deletedTags.forEach {
                    offlineTag in
                    offlineTag.revision = ""
                }
                updatedTagPairs.forEach {
                    offlineTag, onlineTag in
                    onlineTag.offlineContainer = offlineTag.offlineContainer
                    onlineTag.updateOfflineContainer()
                }
                addedTags.forEach {
                    onlineTag in
                    onlineTag.updateOfflineContainer()
                }
            }
            else {
                deletedTags.forEach {
                    offlineTag in
                    self.tags?.removeAll { $0 === offlineTag }
                    offlineTag.revision = ""
                }
                updatedTagPairs.forEach {
                    offlineTag, onlineTag in
                    offlineTag.update(from: onlineTag)
                }
                self.tags?.append(contentsOf: addedTags)
                addedTags.forEach {
                    onlineTag in
                    onlineTag.updateOfflineContainer()
                }
            }
        }
    }
    
    func updateOfflineContainers() {
        folders?.forEach { $0.updateOfflineContainer() }
        passwords?.forEach { $0.updateOfflineContainer() }
        tags?.forEach { $0.updateOfflineContainer() }
    }
    
    func updateAutoFillCredentials() {
        ASCredentialIdentityStore.shared.getState {
            [weak self] state in
            guard state.isEnabled,
                  let self else {
                return
            }
            if Configuration.userDefaults.bool(forKey: "storeOffline"),
               let passwords = self.passwords {
                let credentials = passwords.map { ASPasswordCredentialIdentity(serviceIdentifier: ASCredentialServiceIdentifier(identifier: $0.url, type: .URL), user: $0.username, recordIdentifier: $0.id) }
                ASCredentialIdentityStore.shared.replaceCredentialIdentities(with: credentials)
            }
            else {
                ASCredentialIdentityStore.shared.removeAllCredentialIdentities()
            }
        }
    }
    
    private func completeCredentialIdentifierAutoFill() {
        guard let credentialIdentifier = AutoFillController.default.credentialIdentifier else {
            return
        }
        guard let complete = AutoFillController.default.complete,
              let password = passwords?.first(where: { $0.id == credentialIdentifier }) else {
            AutoFillController.default.credentialIdentifier = nil
            return
        }
        switch AutoFillController.default.mode {
        case .app:
            break
        case .provider:
            complete(password.username, password.password)
        case .extension:
            guard let currentOtp = password.otp?.current else {
                return
            }
            complete(password.username, currentOtp)
        }
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
            guard let response else {
                folder.state = .creationFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createFolderErrorMessage".localized)
                return
            }
            ShowFolderRequest(session: session, id: response.id).send {
                response in
                guard let response else {
                    folder.state = .creationFailed
                    UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createFolderErrorMessage".localized)
                    return
                }
                folder.id = response.id
                folder.update(from: response)
            }
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
            [weak self] response in
            guard let response else {
                password.state = .creationFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createPasswordErrorMessage".localized)
                return
            }
            ShowPasswordRequest(session: session, id: response.id).send {
                [weak self] response in
                guard let response else {
                    password.state = .creationFailed
                    UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createPasswordErrorMessage".localized)
                    return
                }
                password.id = response.id
                password.update(from: response)
                self?.updateAutoFillCredentials()
            }
        }
    }
    
    func add(tag: Tag) {
        tag.state = .creating
        
        guard let session = SessionController.default.session else {
            tag.state = .creationFailed
            return
        }
        tags?.append(tag)
        
        CreateTagRequest(session: session, tag: tag).send {
            response in
            guard let response else {
                tag.state = .creationFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createTagErrorMessage".localized)
                return
            }
            ShowTagRequest(session: session, id: response.id).send {
                response in
                guard let response else {
                    tag.state = .creationFailed
                    UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_createTagErrorMessage".localized)
                    return
                }
                tag.id = response.id
                tag.update(from: response)
            }
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
            guard let response else {
                folder.state = .updateFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editFolderErrorMessage".localized)
                return
            }
            ShowFolderRequest(session: session, id: response.id).send {
                response in
                guard let response else {
                    folder.state = .updateFailed
                    UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editFolderErrorMessage".localized)
                    return
                }
                folder.update(from: response)
            }
        }
    }
    
    func update(password: Password) {
        password.state = .updating
        
        guard let session = SessionController.default.session else {
            password.state = .updateFailed
            return
        }
        
        UpdatePasswordRequest(session: session, password: password).send {
            [weak self] response in
            guard let response else {
                password.state = .updateFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editPasswordErrorMessage".localized)
                return
            }
            ShowPasswordRequest(session: session, id: response.id).send {
                [weak self] response in
                guard let response else {
                    password.state = .updateFailed
                    UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editPasswordErrorMessage".localized)
                    return
                }
                password.update(from: response)
                self?.updateAutoFillCredentials()
            }
        }
    }
    
    func update(tag: Tag) {
        tag.state = .updating
        
        guard let session = SessionController.default.session else {
            tag.state = .updateFailed
            return
        }
        
        UpdateTagRequest(session: session, tag: tag).send {
            response in
            guard let response else {
                tag.state = .updateFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editTagErrorMessage".localized)
                return
            }
            ShowTagRequest(session: session, id: response.id).send {
                response in
                guard let response else {
                    tag.state = .updateFailed
                    UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_editTagErrorMessage".localized)
                    return
                }
                tag.update(from: response)
            }
        }
    }
    
    func delete(folder: Folder) {
        folder.state = .deleting
        
        guard let session = SessionController.default.session,
              let folders,
              let passwords else {
            folder.state = .deletionFailed
            return
        }
        
        self.folders?.removeAll { $0 === folder }
        
        let childFolders = folders.filter { $0.isDescendentOf(folder: folder, in: folders) }
        let childPasswords = passwords.filter {
            password in
            childFolders.contains { $0.id == password.folder }
        }
        self.folders?.removeAll {
            folder in
            childFolders.contains { $0 === folder }
        }
        self.passwords?.removeAll {
            password in
            childPasswords.contains { $0 === password }
        }
        
        DeleteFolderRequest(session: session, folder: folder).send {
            [weak self] response in
            guard response != nil else {
                self?.folders?.append(folder)
                self?.folders?.append(contentsOf: childFolders)
                self?.passwords?.append(contentsOf: childPasswords)
                folder.state = .deletionFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_deleteFolderErrorMessage".localized)
                return
            }
            folder.revision = ""
            childFolders.forEach { $0.revision = "" }
            childPasswords.forEach { $0.revision = "" }
            if !childPasswords.isEmpty {
                self?.updateAutoFillCredentials()
            }
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
            self?.updateAutoFillCredentials()
        }
    }
    
    func delete(tag: Tag) {
        tag.state = .deleting
        
        guard let session = SessionController.default.session else {
            tag.state = .deletionFailed
            return
        }
        tags?.removeAll { $0 === tag }
        
        DeleteTagRequest(session: session, tag: tag).send {
            [weak self] response in
            guard response != nil else {
                self?.tags?.append(tag)
                tag.state = .deletionFailed
                UIAlertController.presentGlobalAlert(title: "_error".localized, message: "_deleteTagErrorMessage".localized)
                return
            }
            tag.revision = ""
        }
    }
    
    func processEntries(folder: Folder, tag: Tag?, searchTerm: String, defaultSorting: Sorting?) -> [Entry]? {
        guard var passwords,
              var folders,
              var tags else {
            return nil
        }
        let searchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        let filterBy = AutoFillController.default.mode != .extension ? filterBy : .otps
        let sortBy = defaultSorting ?? sortBy
        let reversed = defaultSorting != nil ? false : reversed
        
        /// Apply filter to folders
        switch filterBy {
        case .all:
            guard tag == nil else {
                fallthrough
            }
            folders = []
        case .favorites:
            guard folder.isBaseFolder,
                  tag == nil else {
                fallthrough
            }
            let favoriteFolders = folders.filter { $0.favorite }
            if searchTerm.isEmpty {
                folders = favoriteFolders
            }
            else {
                folders = folders.filter {
                    folder in
                    folder.favorite ||
                    favoriteFolders.contains { folder.isDescendentOf(folder: $0, in: folders) }
                }
            }
        case .folders:
            guard tag == nil else {
                fallthrough
            }
            if searchTerm.isEmpty {
                folders = folders.filter { $0.parent == folder.id }
            }
            else {
                folders = folders.filter { $0.isDescendentOf(folder: folder, in: folders) && $0 !== folder }
            }
        case .tags:
            folders = []
        case .otps:
            folders = []
        }
        
        /// Apply filter to passwords
        switch filterBy {
        case .all:
            guard tag == nil else {
                fallthrough
            }
        case .favorites:
            guard folder.isBaseFolder,
                  tag == nil else {
                fallthrough
            }
            if searchTerm.isEmpty {
                passwords = passwords.filter { $0.favorite }
            }
            else {
                let favoriteFolders = folders.filter { $0.favorite }
                let favoriteTags = tags.filter { $0.favorite }
                passwords = passwords.filter {
                    password in
                    password.favorite ||
                    favoriteFolders.contains { password.isDescendentOf(folder: $0, in: folders) } ||
                    password.tags.contains {
                        tagId in
                        favoriteTags.contains { $0.id == tagId }
                    }
                }
            }
        case .folders:
            guard tag == nil else {
                fallthrough
            }
            if searchTerm.isEmpty {
                passwords = passwords.filter { $0.folder == folder.id }
            }
            else {
                passwords = passwords.filter { $0.isDescendentOf(folder: folder, in: folders) }
            }
        case .tags:
            if let tag {
                passwords = passwords.filter { $0.tags.contains(tag.id) }
            }
            else if searchTerm.isEmpty {
                passwords = []
            }
            else {
                passwords = passwords.filter {
                    password in
                    password.tags.contains {
                        tagId in
                        tags.contains { $0.id == tagId }
                    }
                }
            }
        case .otps:
            passwords = passwords.filter { $0.otp != nil }
        }
        
        /// Apply filter to tags
        switch filterBy {
        case .all:
            guard tag == nil else {
                fallthrough
            }
            tags = []
        case .favorites:
            guard folder.isBaseFolder,
                  tag == nil else {
                fallthrough
            }
            tags = tags.filter { $0.favorite }
        case .folders:
            guard tag == nil else {
                fallthrough
            }
            tags = []
        case .tags:
            if tag != nil {
                tags = []
            }
        case .otps:
            tags = []
        }
        
        /// Sort folders
        switch sortBy {
        case .label:
            folders.sort { $0.label.compare($1.label, options: [.caseInsensitive, .diacriticInsensitive, .numeric]) == .orderedAscending }
        case .updated:
            folders.sort { $0.updated > $1.updated }
        default:
            break
        }
        
        /// Sort passwords
        switch sortBy {
        case .label:
            passwords.sort { $0.label.compare($1.label, options: [.caseInsensitive, .diacriticInsensitive, .numeric]) == .orderedAscending }
        case .updated:
            passwords.sort { $0.updated > $1.updated }
        case .username:
            passwords.sort { $0.username.compare($1.username, options: [.caseInsensitive, .diacriticInsensitive, .numeric]) == .orderedAscending }
            passwords.sort { !$0.username.isEmpty && $1.username.isEmpty }
        case .url:
            passwords.sort { $0.url.compare($1.url, options: [.caseInsensitive, .diacriticInsensitive, .numeric]) == .orderedAscending }
            passwords.sort { !$0.url.isEmpty && $1.url.isEmpty }
        case .status:
            passwords.sort { $0.statusCode > $1.statusCode }
        }
        
        /// Sort tags
        switch sortBy {
        case .label:
            tags.sort { $0.label.compare($1.label, options: [.caseInsensitive, .diacriticInsensitive, .numeric]) == .orderedAscending }
        case .updated:
            tags.sort { $0.updated > $1.updated }
        default:
            break
        }
        
        /// Reverse order if necessary
        if reversed {
            folders.reverse()
            passwords.reverse()
            tags.reverse()
        }
        
        /// Apply search term
        let unsearchedEntries: [Entry] = folders.map { .folder($0) } + tags.map { .tag($0) } + passwords.map { .password($0) }
        if searchTerm.isEmpty {
            return unsearchedEntries
        }
        return unsearchedEntries
            .map { $0.score(searchTerm: searchTerm) }
            .zip(with: unsearchedEntries)
            .filter { $0.0 > 0.5 }
            .sorted { $0.0 > $1.0 }
            .map { $0.1 }
    }
    
    func processSuggestions(serviceURLs: [URL]?) -> [Password]? {
        guard let passwords,
              let serviceURLs else {
            return nil
        }
        
        return passwords
            .map {
                password -> Double in
                serviceURLs
                    .map { password.score(searchTerm: $0.absoluteString) }
                    .reduce(0.0, +)
            }
            .zip(with: passwords)
            .filter { AutoFillController.default.mode != .extension || $0.1.otp != nil }
            .filter { $0.0 > 0.5 }
            .sorted { $0.0 > $1.0 }
            .prefix(5)
            .map { $0.1 }
    }
    
    static func tags(for tagIds: [String], in tags: [Tag]) -> (valid: [Tag], invalid: [String]) {
        tagIds
            .reduce((valid: [], invalid: [])) {
                result, tagId in
                var result = result
                if let tag = tags.first(where: { $0.id == tagId }) {
                    result.valid.append(tag)
                }
                else {
                    result.invalid.append(tagId)
                }
                return result
            }
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
        case tags
        case otps
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


#if DEBUG

extension EntriesController: MockObject {
    
    static var mock: EntriesController {
        EntriesController(folders: Folder.mocks, passwords: Password.mocks, tags: Tag.mocks)
    }
    
}

#endif
