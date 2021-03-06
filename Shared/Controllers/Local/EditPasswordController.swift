import SwiftUI


final class EditPasswordController: ObservableObject {
    
    let password: Password
    private let addPassword: () -> Void
    private let updatePassword: () -> Void
    
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
    @Published var passwordCustomFields: [Password.CustomField]
    @Published var passwordNotes: String
    @Published var passwordFavorite: Bool
    @Published var showErrorAlert = false
    @Published var showProgressView = false
    
    init(password: Password, addPassword: @escaping () -> Void, updatePassword: @escaping () -> Void) {
        self.password = password
        self.addPassword = addPassword
        self.updatePassword = updatePassword
        passwordPassword = password.password
        passwordLabel = password.label
        passwordUsername = password.username
        passwordUrl = password.url
        passwordCustomFields = password.customFields
        passwordNotes = password.notes
        passwordFavorite = password.favorite
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
        password.customFields = passwordCustomFields
        password.notes = passwordNotes
        password.favorite = passwordFavorite
        
        if password.id.isEmpty {
            addPassword()
        }
        else {
            updatePassword()
        }
    }
    
}
