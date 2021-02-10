import SwiftUI
import CryptoKit


final class EditPasswordController: ObservableObject {
    
    let password: Password
    private let addPassword: () -> Void
    private let updatePassword: () -> Void
    
    @AppStorage("generatorNumbers", store: UserDefaults(suiteName: Configuration.appGroup)!) var generatorNumbers = true {
        willSet {
            /// Extend @AppStorage behaviour to be more similar to @Published
            objectWillChange.send()
        }
    }
    @AppStorage("generatorSpecial", store: UserDefaults(suiteName: Configuration.appGroup)!) var generatorSpecial = true {
        willSet {
            /// Extend @AppStorage behaviour to be more similar to @Published
            objectWillChange.send()
        }
    }
    @AppStorage("generatorLength", store: UserDefaults(suiteName: Configuration.appGroup)!) var generatorLength = 36.0 {
        willSet {
            /// Extend @AppStorage behaviour to be more similar to @Published
            objectWillChange.send()
        }
    }
    @Published var passwordPassword: String
    @Published var passwordLabel: String
    @Published var passwordUsername: String
    @Published var passwordUrl: String
    @Published var passwordNotes: String
    @Published var showErrorAlert = false
    
    init(password: Password, addPassword: @escaping () -> Void, updatePassword: @escaping () -> Void) {
        self.password = password
        self.addPassword = addPassword
        self.updatePassword = updatePassword
        passwordPassword = password.password
        passwordLabel = password.label
        passwordUsername = password.username
        passwordUrl = password.url
        passwordNotes = password.notes
    }
    
    func generatePassword() {
        guard let credentials = CredentialsController.default.credentials else {
            showErrorAlert = true
            return
        }
        
        PasswordServiceRequest(credentials: credentials, numbers: generatorNumbers, special: generatorSpecial).send {
            [weak self] password in
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
            password.hash = Insecure.SHA1.hash(data: passwordPassword.data(using: .utf8)!).map { String(format: "%02x", $0) }.joined()
            print(password.hash)
        }
        password.updated = Date()
        
        password.password = passwordPassword
        password.label = passwordLabel
        password.username = passwordUsername
        password.url = passwordUrl
        password.notes = passwordNotes
        
        if password.id.isEmpty {
            addPassword()
        }
        else {
            updatePassword()
        }
    }
    
}
