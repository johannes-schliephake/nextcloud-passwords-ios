import SwiftUI


final class EditPasswordController: ObservableObject {
    
    let password: Password
    let folders: [Folder]
    let tags: [Tag]
    private let addPassword: () -> Void
    private let updatePassword: () -> Void
    let addTag: (Tag) -> Void
    
    @Published var generatorNumbers = Configuration.userDefaults.object(forKey: "generatorNumbers") as? Bool ?? true {
        willSet {
            Configuration.userDefaults.set(newValue, forKey: "generatorNumbers")
        }
    }
    @Published var generatorSpecial = Configuration.userDefaults.object(forKey: "generatorSpecial") as? Bool ?? true {
        willSet {
            Configuration.userDefaults.set(newValue, forKey: "generatorSpecial")
        }
    }
    @Published var generatorLength = Configuration.userDefaults.object(forKey: "generatorLength") as? Double ?? 36.0 {
        willSet {
            Configuration.userDefaults.set(newValue, forKey: "generatorLength")
        }
    }
    @Published var passwordPassword: String
    @Published var passwordLabel: String
    @Published var passwordUsername: String
    @Published var passwordUrl: String
    @Published var passwordCustomUserFields: [Password.CustomField]
    @Published var passwordNotes: String
    @Published var passwordFavorite: Bool
    @Published var passwordTags: [Tag]
    @Published var passwordFolder: String
    @Published var showErrorAlert = false
    @Published var showProgressView = false
    
    let passwordCustomDataFields: [Password.CustomField]
    
    init(password: Password, folders: [Folder], tags: [Tag], addPassword: @escaping () -> Void, updatePassword: @escaping () -> Void, addTag: @escaping (Tag) -> Void) {
        self.password = password
        self.folders = folders
        self.tags = tags
        self.addPassword = addPassword
        self.updatePassword = updatePassword
        self.addTag = addTag
        passwordPassword = password.password
        passwordLabel = password.label
        passwordUsername = password.username
        passwordUrl = password.url
        passwordCustomUserFields = password.customFields.filter { $0.type != .data }
        passwordCustomDataFields = password.customFields.filter { $0.type == .data }
        passwordNotes = password.notes
        passwordFavorite = password.favorite
        passwordTags = password.tags(in: tags)
        passwordFolder = password.folder
    }
    
    var hasChanges: Bool {
        passwordPassword != password.password ||
        passwordLabel != password.label ||
        passwordUsername != password.username ||
        passwordUrl != password.url ||
        passwordCustomUserFields != password.customFields ||
        passwordNotes != password.notes ||
        passwordFavorite != password.favorite ||
        passwordTags.map { $0.id }.sorted() != password.tags.filter { tagId in tags.contains { $0.id == tagId } }.sorted() ||
        passwordFolder != password.folder
    }
    
    var editIsValid: Bool {
        1...64 ~= passwordLabel.count &&
        passwordUsername.count <= 64 &&
        1...256 ~= passwordPassword.count &&
        passwordUrl.count <= 2048 &&
        passwordNotes.count <= 4096 &&
        passwordCustomUserFields.count + passwordCustomDataFields.count <= 20 &&
        passwordCustomUserFields.allSatisfy { 1...48 ~= $0.label.count && 1...320 ~= $0.value.count }
    }
    
    func generatePassword() {
        guard let session = SessionController.default.session else {
            showErrorAlert = true
            return
        }
        
        showProgressView = true
        PasswordServiceRequest(session: session, numbers: generatorNumbers, special: generatorSpecial).send {
            [weak self] password in
            self?.showProgressView = false
            guard let password = password,
                  let generatorLength = self?.generatorLength else {
                self?.showErrorAlert = true
                return
            }
            self?.passwordPassword = String(password.prefix(Int(generatorLength)))
        }
    }
    
    func applyToPassword() {
        if password.id.isEmpty {
            password.created = Date()
        }
        if password.password != passwordPassword {
            password.edited = Date()
            password.hash = Crypto.SHA1.hash(passwordPassword.data(using: .utf8)!)
        }
        password.updated = Date()
        
        password.password = passwordPassword
        password.label = passwordLabel
        password.username = passwordUsername
        password.url = passwordUrl
        password.customFields = passwordCustomUserFields + passwordCustomDataFields
        password.notes = passwordNotes
        password.favorite = passwordFavorite
        password.tags = passwordTags.map { $0.id }
        password.folder = passwordFolder
        
        if password.id.isEmpty {
            addPassword()
        }
        else {
            updatePassword()
        }
    }
    
}
